// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxGenArt721, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IDutchAuction} from "src/interfaces/IDutchAuction.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

contract DutchAuction is IDutchAuction {
    using SafeCastLib for uint256;

    struct DAInfo {
        uint256[] prices;
        uint256 stepLength;
        bool refunded;
    }

    bytes32 internal constant NULL_RESERVE = keccak256(abi.encode(ReserveInfo(0, 0, 0)));
    mapping(address => DAInfo) public auctionInfo;
    mapping(address => ReserveInfo) public reserves;
    mapping(address => uint256) public saleProceeds;
    /// Refund related info
    mapping(address => mapping(address => uint256)) public cumulativeMints;
    mapping(address => mapping(address => uint256)) public cumulativeMintCost;
    mapping(address => uint256) public lastPrice;

    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintData) external {
        DAInfo memory daInfo = abi.decode(_mintData, (DAInfo));

        if (_reserve.startTime > _reserve.endTime) revert InvalidTimes();
        if (_reserve.startTime > _reserve.endTime) revert InvalidTimes();
        if (!(daInfo.prices.length * daInfo.stepLength == _reserve.endTime - _reserve.startTime)) revert InvalidStep();

        require(daInfo.prices.length > 1, "Invalid Price curve");
        for (uint256 i =1; i < daInfo.prices.length; i++) { 
            if (!(daInfo.prices[i-1] > daInfo.prices[i])) revert PricesOutOfOrder();
        }
        if (block.timestamp >= _reserve.startTime) revert InvalidTimes();
        if (_reserve.allocation == 0) revert InvalidAllocation();
        reserves[msg.sender] = _reserve;
        auctionInfo[msg.sender] = daInfo;
    }

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
        saleProceeds[_token] += price * _amount;
        IFxGenArt721(_token).mint(_to, _amount);
    }

    function refund(address _token, address _who) external {
        uint256 userCost = cumulativeMintCost[_token][_who];
        uint256 numMinted = cumulativeMints[_token][_who];
        delete cumulativeMintCost[_token][_who];
        delete cumulativeMints[_token][_who];
        uint256 refundAmount = userCost - numMinted * lastPrice[_token];
    }

    function withdraw(address _token) external {
        if (_token == address(0)) revert InvalidToken();
        (, address saleReceiver) = IFxGenArt721(_token).issuerInfo();
        uint256 proceeds = saleProceeds[_token];
        if (proceeds == 0) revert InsufficientFunds();
        delete saleProceeds[_token];
        SafeTransferLib.safeTransferETH(saleReceiver, proceeds);
    }

    function getPrice(address _token) public view virtual returns (uint256 step, uint256 price) {
        if (block.timestamp < reserves[_token].startTime) revert NotStarted();
        uint256 timeSinceStart = block.timestamp - reserves[_token].startTime;
        step = timeSinceStart / auctionInfo[_token].stepLength;
        if (step >= auctionInfo[_token].prices.length) revert InvalidStep();
        price = auctionInfo[_token].prices[step];
    }
}
