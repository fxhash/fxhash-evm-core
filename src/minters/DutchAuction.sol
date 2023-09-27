// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxGenArt721, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IDutchAuction, IMinter} from "src/interfaces/IDutchAuction.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";
import "src/utils/Constants.sol";

/**
 * @title DutchAuction
 * @dev A contract for Dutch auction minting.
 */
contract DutchAuction is IDutchAuction {
    using SafeCastLib for uint256;

    /// @inheritdoc IDutchAuction
    mapping(address => DAInfo) public auctionInfo;

    /// @inheritdoc IDutchAuction
    mapping(address => ReserveInfo) public reserves;

    /// @inheritdoc IDutchAuction
    mapping(address => uint256) public saleProceeds;

    /// @inheritdoc IDutchAuction
    mapping(address => mapping(address => uint256)) public cumulativeMints;

    /// @inheritdoc IDutchAuction
    mapping(address => mapping(address => uint256)) public cumulativeMintCost;

    /// @inheritdoc IDutchAuction
    mapping(address => uint256) public lastPrice;

    /// @inheritdoc IMinter
    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintData) external {
        DAInfo memory daInfo = abi.decode(_mintData, (DAInfo));

        if (_reserve.startTime > _reserve.endTime) revert InvalidTimes();
        if (_reserve.startTime > _reserve.endTime) revert InvalidTimes();
        if (!(daInfo.prices.length * daInfo.stepLength == _reserve.endTime - _reserve.startTime)) {
            revert InvalidStep();
        }

        require(daInfo.prices.length > 1, "Invalid Price curve");
        for (uint256 i = 1; i < daInfo.prices.length; i++) {
            if (!(daInfo.prices[i - 1] > daInfo.prices[i])) revert PricesOutOfOrder();
        }
        if (block.timestamp >= _reserve.startTime) revert InvalidTimes();
        if (_reserve.allocation == 0) revert InvalidAllocation();
        reserves[msg.sender] = _reserve;
        auctionInfo[msg.sender] = daInfo;

        emit DutchAuctionMintDetails(msg.sender, _reserve, daInfo);
    }

    /// @inheritdoc IDutchAuction
    function buy(address _token, uint256 _amount, address _to) external payable {
        ReserveInfo storage reserve = reserves[_token];
        if (_to == address(0)) revert AddressZero();
        if (_amount == 0) revert InvalidAmount();
        if (NULL_RESERVE == keccak256(abi.encode(reserve))) revert InvalidToken();
        if (block.timestamp < reserve.startTime) revert NotStarted();
        if (block.timestamp > reserve.endTime) revert Ended();
        if (_amount > reserve.allocation) revert TooMany();

        (, uint256 price) = getPrice(_token);
        if (msg.value != price * _amount) revert InvalidPayment();

        reserve.allocation -= _amount.safeCastTo128();
        if (reserve.allocation == 0 && auctionInfo[_token].refunded) lastPrice[_token] = price;
        cumulativeMints[_token][msg.sender] += _amount;
        cumulativeMintCost[_token][msg.sender] += price * _amount;
        saleProceeds[_token] += price * _amount;
        emit Purchase(_token, msg.sender, _to, _amount, price);

        IFxGenArt721(_token).mint(_to, _amount);
    }

    /// @inheritdoc IDutchAuction
    function refund(address _token, address _who) external {
        if (_token == address(0)) revert InvalidToken();
        if (_who == address(0)) revert AddressZero();
        if (!(auctionInfo[_token].refunded && lastPrice[_token] > 0)) revert NoRefund();
        uint256 userCost = cumulativeMintCost[_token][_who];
        uint256 numMinted = cumulativeMints[_token][_who];
        delete cumulativeMintCost[_token][_who];
        delete cumulativeMints[_token][_who];
        uint256 refundAmount = userCost - numMinted * lastPrice[_token];
        if (refundAmount == 0) revert NoRefund();

        emit RefundClaimed(_token, _who, refundAmount);
        SafeTransferLib.safeTransferETH(_who, refundAmount);
    }

    /// @inheritdoc IDutchAuction
    function withdraw(address _token) external {
        if (_token == address(0)) revert InvalidToken();
        (, address saleReceiver) = IFxGenArt721(_token).issuerInfo();
        uint256 proceeds = saleProceeds[_token];
        if (proceeds == 0) revert InsufficientFunds();
        delete saleProceeds[_token];
        emit SaleProceedsWithdrawn(_token, saleReceiver, proceeds);

        SafeTransferLib.safeTransferETH(saleReceiver, proceeds);
    }

    /// @inheritdoc IDutchAuction
    function getPrice(address _token) public view virtual returns (uint256 step, uint256 price) {
        if (block.timestamp < reserves[_token].startTime) revert NotStarted();
        uint256 timeSinceStart = block.timestamp - reserves[_token].startTime;
        step = timeSinceStart / auctionInfo[_token].stepLength;
        if (step >= auctionInfo[_token].prices.length) revert InvalidStep();
        price = auctionInfo[_token].prices[step];
    }
}
