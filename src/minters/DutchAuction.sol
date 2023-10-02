// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxGenArt721, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IDutchAuction, IFxMinter} from "src/interfaces/IDutchAuction.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

/**
 * @title DutchAuction
 * @dev A contract for Dutch auction minting.
 */
contract DutchAuction is IDutchAuction {
    using SafeCastLib for uint256;

    /// @inheritdoc IDutchAuction
    mapping(address => DAInfo[]) public auctionInfo;

    /// @inheritdoc IDutchAuction
    mapping(address => ReserveInfo[]) public reserves;

    /// @inheritdoc IDutchAuction
    mapping(address => mapping(uint256 => uint256)) public saleProceeds;

    /// @inheritdoc IDutchAuction
    mapping(address => mapping(uint256 => mapping(address => uint256))) public cumulativeMints;

    /// @inheritdoc IDutchAuction
    mapping(address => mapping(uint256 => mapping(address => uint256))) public cumulativeMintCost;

    /// @inheritdoc IDutchAuction
    mapping(address => mapping(uint256 => uint256)) public lastPrice;

    /// @inheritdoc IFxMinter
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
        uint256 reserveId = reserves[msg.sender].length;
        reserves[msg.sender].push(_reserve);
        auctionInfo[msg.sender].push(daInfo);

        emit MintDetailsSet(msg.sender, reserveId, _reserve, daInfo);
    }

    /// @inheritdoc IDutchAuction
    function buy(address _token, uint256 _reserveId, uint256 _amount, address _to)
        external
        payable
    {
        if (reserves[_token].length == 0) revert InvalidToken();
        ReserveInfo storage reserve = reserves[_token][_reserveId];
        if (_to == address(0)) revert AddressZero();
        if (_amount == 0) revert InvalidAmount();
        if (block.timestamp < reserve.startTime) revert NotStarted();
        if (block.timestamp > reserve.endTime) revert Ended();
        if (_amount > reserve.allocation) revert TooMany();

        (, uint256 price) = getPrice(_token, _reserveId);
        if (msg.value != price * _amount) revert InvalidPayment();

        reserve.allocation -= _amount.safeCastTo128();
        if (reserve.allocation == 0 && auctionInfo[_token][_reserveId].refunded) {
            lastPrice[_token][_reserveId] = price;
        }
        cumulativeMints[_token][_reserveId][msg.sender] += _amount;
        cumulativeMintCost[_token][_reserveId][msg.sender] += price * _amount;
        saleProceeds[_token][_reserveId] += price * _amount;
        emit Purchase(_token, _reserveId, msg.sender, _to, _amount, price);

        IFxGenArt721(_token).mint(_to, _amount);
    }

    /// @inheritdoc IDutchAuction
    function refund(address _token, uint256 _reserveId, address _who) external {
        if (reserves[_token].length == 0) revert InvalidToken();
        if (_token == address(0)) revert InvalidToken();
        if (_who == address(0)) revert AddressZero();
        ReserveInfo storage reserve = reserves[_token][_reserveId];
        if (!(auctionInfo[_token][_reserveId].refunded && lastPrice[_token][_reserveId] > 0)) {
            revert NoRefund();
        }
        if (block.timestamp < reserve.endTime && reserve.allocation > 0) revert NotEnded();
        uint256 userCost = cumulativeMintCost[_token][_reserveId][_who];
        uint256 numMinted = cumulativeMints[_token][_reserveId][_who];
        delete cumulativeMintCost[_token][_reserveId][_who];
        delete cumulativeMints[_token][_reserveId][_who];
        uint256 refundAmount = userCost - numMinted * lastPrice[_token][_reserveId];
        if (refundAmount == 0) revert NoRefund();

        emit RefundClaimed(_token, _reserveId, _who, refundAmount);
        SafeTransferLib.safeTransferETH(_who, refundAmount);
    }

    /// @inheritdoc IDutchAuction
    function withdraw(address _token, uint256 _reserveId) external {
        if (reserves[_token].length == 0) revert InvalidToken();
        ReserveInfo storage reserve = reserves[_token][_reserveId];
        if (_token == address(0)) revert InvalidToken();
        if (block.timestamp < reserve.endTime && reserve.allocation > 0) revert NotEnded();
        (, address saleReceiver) = IFxGenArt721(_token).issuerInfo();
        uint256 proceeds = saleProceeds[_token][_reserveId];
        if (proceeds == 0) revert InsufficientFunds();
        delete saleProceeds[_token][_reserveId];
        emit Withdrawn(_token, _reserveId, saleReceiver, proceeds);

        SafeTransferLib.safeTransferETH(saleReceiver, proceeds);
    }

    /// @inheritdoc IDutchAuction
    function getPrice(address _token, uint256 _reserveId)
        public
        view
        virtual
        returns (uint256 step, uint256 price)
    {
        if (block.timestamp < reserves[_token][_reserveId].startTime) revert NotStarted();
        uint256 timeSinceStart = block.timestamp - reserves[_token][_reserveId].startTime;
        step = timeSinceStart / auctionInfo[_token][_reserveId].stepLength;
        if (step >= auctionInfo[_token][_reserveId].prices.length) revert InvalidStep();
        price = auctionInfo[_token][_reserveId].prices[step];
    }
}
