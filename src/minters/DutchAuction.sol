// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Allowlist} from "src/minters/extensions/Allowlist.sol";
import {LibBitmap} from "solady/src/utils/LibBitmap.sol";
import {LibMap} from "solady/src/utils/LibMap.sol";
import {MintPass} from "src/minters/extensions/MintPass.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IDutchAuction, AuctionInfo, MinterInfo, RefundInfo} from "src/interfaces/IDutchAuction.sol";
import {IFxGenArt721, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IToken} from "src/interfaces/IToken.sol";

/**
 * @title DutchAuction
 * @author fx(hash)
 * @dev See the documentation in {IDutchAuction}
 */
contract DutchAuction is IDutchAuction, Allowlist, MintPass {
    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Mapping of token address to reserve ID to Bitmap of claimed merkle tree slots
     */
    mapping(address => mapping(uint256 => LibBitmap.Bitmap)) internal claimedMerkleTreeSlots_;

    /**
     * @dev Mapping of token address to reserve ID to Bitmap of claimed mint passes
     */
    mapping(address => mapping(uint256 => LibBitmap.Bitmap)) internal claimedMintPasses_;

    /**
     * @dev Mapping of token address to timestamp of latest update made for token reserves
     */
    LibMap.Uint40Map internal latestUpdates_;

    /**
     * @inheritdoc IDutchAuction
     */
    mapping(address => AuctionInfo[]) public auctions;

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

    /**
     * @inheritdoc IDutchAuction
     */
    mapping(address => mapping(uint256 => uint256)) public numberMinted;

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IDutchAuction
     */
    function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable {
        bytes32 merkleRoot = _getMerkleRoot(_token, _reserveId);
        address signer = signingAuthorities[_token][_reserveId];
        if (merkleRoot != bytes32(0)) revert NoPublicMint();
        if (signer != address(0)) revert AddressZero();
        _buy(_token, _reserveId, _amount, _to);
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
        bytes32 merkleRoot = _getMerkleRoot(_token, _reserveId);
        if (merkleRoot == bytes32(0)) revert NoAllowlist();
        LibBitmap.Bitmap storage claimBitmap = claimedMerkleTreeSlots_[_token][_reserveId];
        uint256 amount = _proofs.length;
        for (uint256 i; i < amount; ++i) {
            _claimSlot(_token, _reserveId, _indexes[i], _proofs[i], claimBitmap);
        }

        _buy(_token, _reserveId, amount, _to);
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
        address signer = signingAuthorities[_token][_reserveId];
        if (signer == address(0)) revert NoSigningAuthority();
        LibBitmap.Bitmap storage claimBitmap = claimedMintPasses_[_token][_reserveId];
        _claimMintPass(_token, _reserveId, _index, _signature, claimBitmap);
        _buy(_token, _reserveId, _amount, _to);
    }

    /**
     * @inheritdoc IDutchAuction
     */
    function refund(address _token, uint256 _reserveId, address _buyer) external {
        // Validates token address, reserve information and given account
        _validateInput(_token, _reserveId, _buyer);

        ReserveInfo storage reserve = reserves[_token][_reserveId];
        uint256 lastPrice = refunds[_token][_reserveId].lastPrice;

        bool refundAuction = auctions[_token][_reserveId].refunded;
        // Checks if refunds are enabled and there is a last price
        if (!(refundAuction && lastPrice > 0)) {
            revert NoRefund();
        }
        // Checks if the auction has ended and if the reserve allocation is fully sold out
        if (block.timestamp < reserve.endTime && reserve.allocation > 0) revert NotEnded();
        // checks if the rebate auction ended, but didn't sellout.  Refunds lowest price
        if (lastPrice == 0 && refundAuction) {
            lastPrice = _recordLastPrice(reserve, _token, _reserveId);
        }
        // Get the user's refund information
        MinterInfo memory minterInfo = refunds[_token][_reserveId].minterInfo[_buyer];
        uint128 refundAmount = SafeCastLib.safeCastTo128(minterInfo.totalPaid - minterInfo.totalMints * lastPrice);

        // Deletes the minter's refund information
        if (refundAmount == 0) revert NoRefund();
        delete refunds[_token][_reserveId].minterInfo[_buyer];

        emit RefundClaimed(_token, _reserveId, _buyer, refundAmount);

        // Sends refund to the user
        SafeTransferLib.safeTransferETH(_buyer, refundAmount);
    }

    /**
     * @inheritdoc IDutchAuction
     */
    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintDetails) external {
        if (_reserve.allocation == 0) revert InvalidAllocation();
        (AuctionInfo memory daInfo, bytes32 merkleRoot, address signer) = abi.decode(
            _mintDetails,
            (AuctionInfo, bytes32, address)
        );
        if (getLatestUpdate(msg.sender) != block.timestamp) {
            delete reserves[msg.sender];
            delete auctions[msg.sender];
            _setLatestUpdate(msg.sender, block.timestamp);
        }

        // Checks if the step length is evenly divisible by the auction duration
        if ((_reserve.endTime - _reserve.startTime) % daInfo.stepLength != 0) revert InvalidStep();
        uint256 reserveId = reserves[msg.sender].length;
        delete merkleRoots[msg.sender][reserveId];
        delete signingAuthorities[msg.sender][reserveId];

        if (merkleRoot != bytes32(0) && signer != address(0)) revert OnlyAuthorityOrAllowlist();
        if (merkleRoot != bytes32(0)) {
            merkleRoots[msg.sender][reserveId] = merkleRoot;
        }
        if (signer != address(0)) {
            signingAuthorities[msg.sender][reserveId] = signer;
            reserveNonce[msg.sender][reserveId]++;
        }

        // Checks if the price curve is descending
        uint256 pricesLength = daInfo.prices.length;
        if (pricesLength < 2) revert InvalidPriceCurve();
        for (uint256 i = 1; i < pricesLength; ++i) {
            if (!(daInfo.prices[i - 1] > daInfo.prices[i])) revert PricesOutOfOrder();
        }

        // Adds the reserve and auction info to the mappings
        reserves[msg.sender].push(_reserve);
        auctions[msg.sender].push(daInfo);

        emit MintDetailsSet(msg.sender, reserveId, _reserve, merkleRoot, signer, daInfo);
    }

    /**
     * @inheritdoc IDutchAuction
     */
    function withdraw(address _token, uint256 _reserveId) external {
        // Validates token address, reserve information and given account
        uint256 length = reserves[_token].length;
        if (length == 0) revert InvalidToken();
        if (_token == address(0)) revert AddressZero();
        if (_reserveId >= length) revert InvalidReserve();

        ReserveInfo storage reserve = reserves[_token][_reserveId];

        // Checks if the auction has ended and the reserve allocation is fully sold out
        if (block.timestamp < reserve.endTime && reserve.allocation > 0) revert NotEnded();
        (address saleReceiver, ) = IFxGenArt721(_token).issuerInfo();
        uint256 lastPrice = refunds[_token][_reserveId].lastPrice;
        bool refundAuction = auctions[_token][_reserveId].refunded;
        if (lastPrice == 0 && refundAuction) {
            lastPrice = _recordLastPrice(reserve, _token, _reserveId);
        }
        refunds[_token][_reserveId].lastPrice = lastPrice;

        // Gets the sale proceeds for the reserve
        uint256 proceeds;
        if (refundAuction) {
            proceeds = lastPrice * numberMinted[_token][_reserveId];
        } else {
            proceeds = saleProceeds[_token][_reserveId];
        }
        if (proceeds == 0) revert InsufficientFunds();

        // Clears the sale proceeds for the reserve
        delete numberMinted[_token][_reserveId];
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
    function getLatestUpdate(address _token) public view returns (uint40) {
        return LibMap.get(latestUpdates_, uint256(uint160(_token)));
    }

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
    function _buy(address _token, uint256 _reserveId, uint256 _amount, address _to) internal {
        // Validates token address, reserve information and given account
        _validateInput(_token, _reserveId, _to);
        if (_amount == 0) revert InvalidAmount();

        ReserveInfo storage reserve = reserves[_token][_reserveId];

        // Checks if the auction has started and not ended
        if (block.timestamp < reserve.startTime) revert NotStarted();
        if (block.timestamp > reserve.endTime) revert Ended();

        // Checks if the requested amount is within the available allocation for the reserve
        if (_amount > reserve.allocation) revert InvalidAmount();

        AuctionInfo storage daInfo = auctions[_token][_reserveId];
        uint256 price = _getPrice(reserve, daInfo);
        if (msg.value != price * _amount) revert InvalidPayment();

        // Updates the allocation for the reserve
        uint128 packed_amount = SafeCastLib.safeCastTo128(_amount);
        reserve.allocation -= packed_amount;

        // If the reserve allocation is fully sold out and refunds are enabled, store the last price
        if (reserve.allocation == 0 && daInfo.refunded) {
            refunds[_token][_reserveId].lastPrice = price;
        }

        // Updates the minter's total mints and total paid amounts
        uint128 totalPayment = SafeCastLib.safeCastTo128(price * _amount);
        MinterInfo storage minterInfo = refunds[_token][_reserveId].minterInfo[msg.sender];
        minterInfo.totalMints += packed_amount;
        minterInfo.totalPaid += totalPayment;

        // Adds the sale proceeds to the total for the reserve
        saleProceeds[_token][_reserveId] += totalPayment;
        numberMinted[_token][_reserveId] += _amount;
        emit Purchase(_token, _reserveId, msg.sender, _to, _amount, price);

        IToken(_token).mint(_to, _amount, totalPayment);
    }

    /**
     * @dev Sets timestamp of the latest update to token reserves
     */
    function _setLatestUpdate(address _token, uint256 _timestamp) internal {
        LibMap.set(latestUpdates_, uint256(uint160(_token)), uint40(_timestamp));
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

    function _recordLastPrice(
        ReserveInfo memory _reserve,
        address _token,
        uint256 _reserveId
    ) internal returns (uint256 lastPrice) {
        if (block.timestamp > _reserve.endTime && _reserve.allocation > 0) {
            uint256 length = auctions[_token][_reserveId].prices.length;
            lastPrice = auctions[_token][_reserveId].prices[length - 1];
            refunds[_token][_reserveId].lastPrice = lastPrice;
        }
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
}
