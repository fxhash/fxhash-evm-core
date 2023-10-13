// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IDutchAuction, AuctionInfo, MinterInfo, RefundInfo} from "src/interfaces/IDutchAuction.sol";
import {IFxGenArt721, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IMinter} from "src/interfaces/IMinter.sol";
import {Allowlist} from "src/minters/extensions/Allowlist.sol";
import {MintPass} from "src/minters/extensions/MintPass.sol";

/**
 * @title DutchAuction
 * @notice Minter contract for distributing tokens through a Dutch Auction pricing mechanism
 */
contract DutchAuction is IDutchAuction, Allowlist, MintPass {
    /// @inheritdoc IDutchAuction
    mapping(address => AuctionInfo[]) public auctionInfo;
    /// @inheritdoc IDutchAuction
    mapping(address => ReserveInfo[]) public reserves;
    /// @inheritdoc IDutchAuction
    mapping(address => mapping(uint256 => uint256)) public saleProceeds;
    /// @inheritdoc IDutchAuction
    mapping(address => mapping(uint256 => RefundInfo)) public refundInfo;

    /// @inheritdoc IDutchAuction
    mapping(address => mapping(uint256 => bytes32)) public merkleRoots;

    /// @inheritdoc IDutchAuction
    mapping(address => mapping(uint256 => address)) public signingAuthorities;

    /*
     * Mapping of token => reserveId => claimedMintPasses BitMap
     */
    mapping(address => mapping(uint256 => BitMaps.BitMap)) internal claimedMintPasses;

    /*
     * Mapping of token => reserveId => claimedMerkleTreeSlot BitMap
     */
    mapping(address => mapping(uint256 => BitMaps.BitMap)) internal claimedMerkleTreeSlots;

    /// @inheritdoc IMinter
    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintData) external {
        (AuctionInfo memory daInfo, bytes32 merkleRoot, address signer) = abi.decode(
            _mintData,
            (AuctionInfo, bytes32, address)
        );

        // Check if the step length evenly divides the duration of the auction
        if ((_reserve.endTime - _reserve.startTime) % daInfo.stepLength != 0) revert InvalidStep();
        if (merkleRoot != bytes32(0) && signer != address(0)) revert("Cant have both signer and merkle tree");
        uint256 reserveId = reserves[msg.sender].length;
        if (merkleRoot != bytes32(0)) {
            merkleRoots[msg.sender][reserveId] = merkleRoot;
        }
        if (signer != address(0)) {
            signingAuthorities[msg.sender][reserveId] = signer;
        }

        // Check if the price curve is descending
        if (daInfo.prices.length < 2) revert InvalidPriceCurve();
        for (uint256 i = 1; i < daInfo.prices.length; i++) {
            if (!(daInfo.prices[i - 1] > daInfo.prices[i])) revert PricesOutOfOrder();
        }
        if (_reserve.allocation == 0) revert InvalidAllocation();

        // Add the reserve and auction info to the mappings
        reserves[msg.sender].push(_reserve);
        auctionInfo[msg.sender].push(daInfo);

        emit MintDetailsSet(msg.sender, reserveId, _reserve, daInfo);
    }

    function buyAllowlist(
        address _token,
        uint256 _reserveId,
        uint256[] calldata _indexes,
        address _to,
        bytes32[][] calldata _proofs
    ) external payable {
        bytes32 merkleRoot = _getMerkleRoot(_token, _reserveId);
        if (merkleRoot == bytes32(0)) revert NoAllowlist();
        BitMaps.BitMap storage claimBitmap = claimedMerkleTreeSlots[_token][_reserveId];
        for (uint256 i; i < _proofs.length; i++) {
            _claimSlot(claimBitmap, _token, _reserveId, _indexes[i], _proofs[i]);
        }
        uint256 amount = _proofs.length;
        _buy(_token, _reserveId, amount, _to);
    }

    function buyMintPass(
        address _token,
        uint256 _reserveId,
        uint256 _amount,
        address _to,
        uint256 _index,
        bytes calldata _signature
    ) external payable {
        address signer = signingAuthorities[_token][_reserveId];
        if (signer == address(0)) revert NoSigningAuthority();
        BitMaps.BitMap storage claimBitmap = claimedMintPasses[_token][_reserveId];
        _claimMintPass(claimBitmap, _token, _reserveId, _index, _signature);
        _buy(_token, _reserveId, _amount, _to);
    }

    /// @inheritdoc IDutchAuction
    function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable {
        bytes32 merkleRoot = _getMerkleRoot(_token, _reserveId);
        address signer = signingAuthorities[_token][_reserveId];
        if ((merkleRoot != bytes32(0) || signer != address(0))) revert NoPublicMint();
        _buy(_token, _reserveId, _amount, _to);
    }

    /// @inheritdoc IDutchAuction
    function refund(address _token, uint256 _reserveId, address _who) external {
        // Input validation
        _validateInput(_token, _reserveId, _who);

        ReserveInfo storage reserve = reserves[_token][_reserveId];
        uint256 lastPrice = refundInfo[_token][_reserveId].lastPrice;

        // Check if refunds are enabled and there is a last price
        if (!(auctionInfo[_token][_reserveId].refunded && lastPrice > 0)) {
            revert NoRefund();
        }
        // Check if the auction has ended and the reserve allocation is fully sold out
        if (block.timestamp < reserve.endTime && reserve.allocation > 0) revert NotEnded();
        // Get the user's refund information
        MinterInfo memory minterInfo = refundInfo[_token][_reserveId].minterInfo[_who];
        uint128 refundAmount = SafeCastLib.safeCastTo128(minterInfo.totalPaid - minterInfo.totalMints * lastPrice);
        // Delete the minter's refund information
        delete refundInfo[_token][_reserveId].minterInfo[_who];
        if (refundAmount == 0) revert NoRefund();

        emit RefundClaimed(_token, _reserveId, _who, refundAmount);
        // send the refund to the user
        SafeTransferLib.safeTransferETH(_who, refundAmount);
    }

    /// @inheritdoc IDutchAuction
    function withdraw(address _token, uint256 _reserveId) external {
        // Input validation
        uint256 length = reserves[_token].length;
        if (length == 0 || _token == address(0)) revert InvalidToken();
        if (_reserveId >= length) revert InvalidReserve();

        ReserveInfo storage reserve = reserves[_token][_reserveId];
        // Check if the auction has ended and the reserve allocation is fully sold out
        if (block.timestamp < reserve.endTime && reserve.allocation > 0) revert NotEnded();
        (, address saleReceiver) = IFxGenArt721(_token).issuerInfo();

        // Get the sale proceeds for the reserve
        uint256 proceeds = saleProceeds[_token][_reserveId];
        if (proceeds == 0) revert InsufficientFunds();
        // Clear the sale proceeds for the reserve
        delete saleProceeds[_token][_reserveId];

        emit Withdrawn(_token, _reserveId, saleReceiver, proceeds);

        // Transfer the sale proceeds to the sale receiver
        SafeTransferLib.safeTransferETH(saleReceiver, proceeds);
    }

    /// @inheritdoc IDutchAuction
    function getPrice(address _token, uint256 _reserveId) public view returns (uint256) {
        ReserveInfo memory reserve = reserves[_token][_reserveId];
        AuctionInfo storage daInfo = auctionInfo[_token][_reserveId];
        return _getPrice(reserve, daInfo);
    }

    function _buy(address _token, uint256 _reserveId, uint256 _amount, address _to) internal {
        // Input validation
        _validateInput(_token, _reserveId, _to);
        if (_amount == 0) revert InvalidAmount();

        ReserveInfo storage reserve = reserves[_token][_reserveId];

        // Check if the auction has started and not ended
        if (block.timestamp < reserve.startTime) revert NotStarted();
        if (block.timestamp > reserve.endTime) revert Ended();

        // Check if the requested amount is within the available allocation for the reserve
        if (_amount > reserve.allocation) revert InvalidAmount();

        AuctionInfo storage daInfo = auctionInfo[_token][_reserveId];
        uint256 price = _getPrice(reserve, daInfo);
        if (msg.value != price * _amount) revert InvalidPayment();

        // Update the allocation for the reserve
        reserve.allocation -= SafeCastLib.safeCastTo128(_amount);

        // If the reserve allocation is fully sold out and refunds are enabled, store the last price
        if (reserve.allocation == 0 && daInfo.refunded) {
            refundInfo[_token][_reserveId].lastPrice = price;
        }

        // Update the minter's total mints and total paid amounts
        MinterInfo storage minterInfo = refundInfo[_token][_reserveId].minterInfo[msg.sender];
        minterInfo.totalMints += SafeCastLib.safeCastTo128(_amount);
        minterInfo.totalPaid += SafeCastLib.safeCastTo128(price * _amount);

        // Add the sale proceeds to the total for the reserve
        saleProceeds[_token][_reserveId] += price * _amount;
        emit Purchase(_token, _reserveId, msg.sender, _to, _amount, price);

        IFxGenArt721(_token).mintRandom(_to, _amount);
    }

    /**
     * @dev Calculates the current price based on the reserve and auction information
     * @param _reserve The details for the reserve
     * @param _daInfo The dutch auction details
     * @return The current price
     */
    function _getPrice(ReserveInfo memory _reserve, AuctionInfo storage _daInfo) internal view returns (uint256) {
        if (block.timestamp < _reserve.startTime) revert NotStarted();
        uint256 timeSinceStart = block.timestamp - _reserve.startTime;
        // Calculate the step based on the time since the start of the auction and the step length
        uint256 step = timeSinceStart / _daInfo.stepLength;
        // Check if the step is within the range of prices
        if (step >= _daInfo.prices.length) revert InvalidStep();
        return _daInfo.prices[step];
    }

    function _validateInput(address _token, uint256 _reserveId, address _who) internal view {
        uint256 length = reserves[_token].length;
        if (length == 0) revert InvalidToken();
        if (_reserveId >= length) revert InvalidReserve();
        if (_who == address(0)) revert AddressZero();
    }

    function _getMerkleRoot(address _token, uint256 _reserveId) internal view override returns (bytes32) {
        return merkleRoots[_token][_reserveId];
    }

    function _isSigningAuthority(
        address _signer,
        address _token,
        uint256 _reserveId
    ) internal view override returns (bool) {
        return _signer == signingAuthorities[_token][_reserveId];
    }
}
