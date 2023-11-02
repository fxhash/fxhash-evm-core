// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {Allowlist} from "src/minters/extensions/Allowlist.sol";
import {BitFlagsLib} from "src/lib/BitFlagsLib.sol";
import {IDutchAuction, AuctionInfo, MinterInfo, RefundInfo} from "src/interfaces/IDutchAuction.sol";
import {IFxGenArt721, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IToken} from "src/interfaces/IToken.sol";
import {MintPass} from "src/minters/extensions/MintPass.sol";

/**
 * @title DutchAuction
 * @author fx(hash)
 * @dev See the documentation in {IDutchAuction}
 */
contract DutchAuction is IDutchAuction, Allowlist, MintPass {
    using BitFlagsLib for uint16;
    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Mapping of token address to reserve ID to BitMap of claimed merkle tree slots
     */
    mapping(address => mapping(uint256 => BitMaps.BitMap)) internal _claimedMerkleTreeSlots;

    /**
     * @dev Mapping of token address to reserve ID to BitMap of claimed mint passes
     */
    mapping(address => mapping(uint256 => BitMaps.BitMap)) internal _claimedMintPasses;

    /**
     * @inheritdoc IDutchAuction
     */
    mapping(address => AuctionInfo[]) public auctions;

    /**
     * @inheritdoc IDutchAuction
     */
    mapping(address => uint256) public latestUpdates;

    /**
     * @inheritdoc IDutchAuction
     */
    mapping(address => mapping(uint256 => bytes32)) public merkleRoots;

    /**
     * @inheritdoc IDutchAuction
     */
    mapping(address => mapping(uint256 => RefundInfo)) public refunds;

    /**
     * @inheritdoc IDutchAuction
     */
    mapping(address => ReserveInfo[]) public reserves;

    /**
     * @inheritdoc IDutchAuction
     */
    mapping(address => mapping(uint256 => uint256)) public saleProceeds;

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IDutchAuction
     */
    function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable {
        ReserveInfo storage reserve = _getReserveInfo(_token, _reserveId);
        uint16 flags = reserve.flags;
        if (flags.isAllowlisted() || flags.isMintWithPass()) revert NoPublicMint();
        _buy(_token, _reserveId, _amount, _to, reserve);
    }

    /**
     * @inheritdoc IDutchAuction
     */
    function buyAllowlist(
        address _token,
        uint256 _reserveId,
        address _to,
        uint256[] calldata _indexes,
        bytes32[][] calldata _proofs
    ) external payable {
        ReserveInfo storage reserve = _getReserveInfo(_token, _reserveId);
        if (!reserve.flags.isAllowlisted()) revert NoAllowlist();
        BitMaps.BitMap storage claimBitmap = _claimedMerkleTreeSlots[_token][_reserveId];
        for (uint256 i; i < _proofs.length; i++) {
            _claimSlot(_token, _reserveId, _indexes[i], _proofs[i], claimBitmap);
        }
        uint256 amount = _proofs.length;
        _buy(_token, _reserveId, amount, _to, reserve);
    }

    /**
     * @inheritdoc IDutchAuction
     */
    function buyMintPass(
        address _token,
        uint256 _reserveId,
        uint256 _amount,
        address _to,
        uint256 _index,
        bytes calldata _signature
    ) external payable {
        ReserveInfo storage reserve = _getReserveInfo(_token, _reserveId);
        if (!reserve.flags.isMintWithPass()) revert NoSigningAuthority();
        BitMaps.BitMap storage claimBitmap = _claimedMintPasses[_token][_reserveId];
        _claimMintPass(_token, _reserveId, _index, _signature, claimBitmap);
        _buy(_token, _reserveId, _amount, _to, reserve);
    }

    /**
     * @inheritdoc IDutchAuction
     */
    function refund(address _token, uint256 _reserveId, address _buyer) external {
        // Validates token address, reserve information and given account
        _validateInput(_token, _reserveId, _buyer);

        ReserveInfo storage reserve = reserves[_token][_reserveId];
        uint256 lastPrice = refunds[_token][_reserveId].lastPrice;

        // Checks if refunds are enabled and there is a last price
        if (!(auctions[_token][_reserveId].refunded && lastPrice > 0)) {
            revert NoRefund();
        }
        // Checks if the auction has ended and the reserve allocation is fully sold out
        if (block.timestamp < reserve.endTime && reserve.allocation > 0) revert NotEnded();

        // Get the user's refund information
        MinterInfo memory minterInfo = refunds[_token][_reserveId].minterInfo[_buyer];
        uint112 refundAmount = SafeCastLib.safeCastTo112(minterInfo.totalPaid - minterInfo.totalMints * lastPrice);

        // Deletes the minter's refund information
        delete refunds[_token][_reserveId].minterInfo[_buyer];
        if (refundAmount == 0) revert NoRefund();

        emit RefundClaimed(_token, _reserveId, _buyer, refundAmount);

        // Sends refund to the user
        SafeTransferLib.safeTransferETH(_buyer, refundAmount);
    }

    /**
     * @inheritdoc IDutchAuction
     */
    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintDetails) external {
        if (latestUpdates[msg.sender] != block.timestamp) {
            delete reserves[msg.sender];
            delete auctions[msg.sender];
            latestUpdates[msg.sender] = block.timestamp;
        }

        // Checks if the step length is evenly divisible by the auction duration
        uint256 reserveId = reserves[msg.sender].length;

        AuctionInfo memory daInfo = _saveMintDetails(_reserve, reserveId, _reserve.flags, _mintDetails);

        if (_reserve.allocation == 0) revert InvalidAllocation();

        // Adds the reserve and auction info to the mappings
        reserves[msg.sender].push(_reserve);

        emit MintDetailsSet(msg.sender, reserveId, _reserve, daInfo);
    }

    /**
     * @inheritdoc IDutchAuction
     */
    function withdraw(address _token, uint256 _reserveId) external {
        // Validates token address, reserve information and given account
        uint256 length = reserves[_token].length;
        if (length == 0 || _token == address(0)) revert InvalidToken();
        if (_reserveId >= length) revert InvalidReserve();

        ReserveInfo storage reserve = reserves[_token][_reserveId];

        // Checks if the auction has ended and the reserve allocation is fully sold out
        if (block.timestamp < reserve.endTime && reserve.allocation > 0) revert NotEnded();
        (address saleReceiver, ) = IFxGenArt721(_token).issuerInfo();

        // Gets the sale proceeds for the reserve
        uint256 proceeds = saleProceeds[_token][_reserveId];
        if (proceeds == 0) revert InsufficientFunds();

        // Clears the sale proceeds for the reserve
        delete saleProceeds[_token][_reserveId];

        emit Withdrawn(_token, _reserveId, saleReceiver, proceeds);

        // Transfers the sale proceeds to the sale receiver
        SafeTransferLib.safeTransferETH(saleReceiver, proceeds);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                READ FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IDutchAuction
     */
    function getPrice(address _token, uint256 _reserveId) public view returns (uint256) {
        ReserveInfo memory reserve = reserves[_token][_reserveId];
        AuctionInfo storage daInfo = auctions[_token][_reserveId];
        return _getPrice(reserve, daInfo);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Purchases arbitrary amount of tokens at auction price and mints tokens to given account
     */
    function _buy(
        address _token,
        uint256 _reserveId,
        uint256 _amount,
        address _to,
        ReserveInfo storage _reserve
    ) internal {
        // Validates token address, reserve information and given account
        _validateInput(_token, _reserveId, _to);
        if (_amount == 0) revert InvalidAmount();

        // Checks if the auction has started and not ended
        if (block.timestamp < _reserve.startTime) revert NotStarted();
        if (block.timestamp > _reserve.endTime) revert Ended();

        // Checks if the requested amount is within the available allocation for the reserve
        if (_amount > _reserve.allocation) revert InvalidAmount();

        AuctionInfo storage daInfo = auctions[_token][_reserveId];
        uint256 price = _getPrice(_reserve, daInfo);
        if (msg.value != price * _amount) revert InvalidPayment();

        // Updates the allocation for the reserve
        _reserve.allocation -= SafeCastLib.safeCastTo112(_amount);

        // If the reserve allocation is fully sold out and refunds are enabled, store the last price
        if (_reserve.allocation == 0 && daInfo.refunded) {
            refunds[_token][_reserveId].lastPrice = price;
        }

        // Updates the minter's total mints and total paid amounts
        uint128 totalPayment = SafeCastLib.safeCastTo128(price * _amount);
        MinterInfo storage minterInfo = refunds[_token][_reserveId].minterInfo[msg.sender];
        minterInfo.totalMints += SafeCastLib.safeCastTo128(_amount);
        minterInfo.totalPaid += totalPayment;

        // Adds the sale proceeds to the total for the reserve
        saleProceeds[_token][_reserveId] += totalPayment;
        emit Purchase(_token, _reserveId, msg.sender, _to, _amount, price);

        IToken(_token).mint(_to, _amount, totalPayment);
    }

    function _saveMintDetails(
        ReserveInfo calldata _reserve,
        uint256 reserveId,
        uint16 _flags,
        bytes memory _mintDetails
    ) internal returns (AuctionInfo memory auctionInfo) {
        if (_flags.isAllowlisted()) {
            bytes32 merkleRoot;
            (auctionInfo, merkleRoot) = abi.decode(_mintDetails, (AuctionInfo, bytes32));
            merkleRoots[msg.sender][reserveId] = merkleRoot;
        } else if (_flags.isMintWithPass()) {
            address signer;
            (auctionInfo, signer) = abi.decode(_mintDetails, (AuctionInfo, address));
            signingAuthorities[msg.sender][reserveId] = signer;
        } else {
            auctionInfo = abi.decode(_mintDetails, (AuctionInfo));
        }

        if (auctionInfo.prices.length < 2) revert InvalidPriceCurve();
        for (uint256 i = 1; i < auctionInfo.prices.length; i++) {
            if (!(auctionInfo.prices[i - 1] > auctionInfo.prices[i])) revert PricesOutOfOrder();
        }
        if ((_reserve.endTime - _reserve.startTime) % auctionInfo.stepLength != 0) revert InvalidStep();
        auctions[msg.sender].push(auctionInfo);
    }

    /**
     * @dev Gets the merkle root of a token reserve
     */
    function _getMerkleRoot(address _token, uint256 _reserveId) internal view override returns (bytes32) {
        return merkleRoots[_token][_reserveId];
    }

    /**
     * @dev Gets the current price of auction reserve
     */
    function _getPrice(ReserveInfo memory _reserve, AuctionInfo storage _daInfo) internal view returns (uint256) {
        if (block.timestamp < _reserve.startTime) revert NotStarted();
        uint256 timeSinceStart = block.timestamp - _reserve.startTime;

        // Calculates the step based on the time since the start of the auction and the step length
        uint256 step = timeSinceStart / _daInfo.stepLength;

        // Checks if the step is within the range of prices
        if (step >= _daInfo.prices.length) revert InvalidStep();
        return _daInfo.prices[step];
    }

    function _getReserveInfo(address _token, uint256 _reserveId) internal view returns (ReserveInfo storage) {
        uint256 length = reserves[_token].length;
        if (length == 0) revert InvalidToken();
        if (_reserveId >= length) revert InvalidReserve();
        return reserves[_token][_reserveId];
    }

    /**
     * @dev Validates token address, reserve information and given account
     */
    function _validateInput(address _token, uint256 _reserveId, address _buyer) internal view {
        uint256 length = reserves[_token].length;
        if (length == 0) revert InvalidToken();
        if (_reserveId >= length) revert InvalidReserve();
        if (_buyer == address(0)) revert AddressZero();
    }

    function _validatePurchase(uint256 _amount, ReserveInfo storage _reserve) internal view {}
}
