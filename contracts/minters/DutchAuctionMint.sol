// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Minted} from "contracts/minters/base/Minted.sol";
import {Minter, Reserve} from "contracts/minters/base/Minter.sol";
import {IWETH} from "contracts/interfaces/IWETH.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";

contract DutchAuctionMint is Minter {
    using SafeCastLib for uint256;

    struct DAInfo {
        uint256[] prices;
        uint256 stepLength;
    }

    bytes32 internal constant NULL_RESERVE = keccak256(abi.encode(Reserve(0, 0, 0)));
    mapping(address => DAInfo) public auctionInfo;
    mapping(address => Reserve) public reserves;
    mapping(address => uint256) public saleProceeds;

    error InvalidToken();
    error NotStarted();
    error Ended();
    error TooMany();
    error InvalidStep();

    /*
     * Record the starting price of a token scaled by 1e18.
     * That will be sold along a DA at a fixed linear decay rate starting at some start time
     */
    function setMintDetails(Reserve calldata _reserve, bytes calldata _mintData) external {
        DAInfo memory daInfo = abi.decode(_mintData, (DAInfo));
        require(
            daInfo.prices.length * daInfo.stepLength == _reserve.endTime - _reserve.startTime,
            "Invalid length"
        );
        require(_reserve.startTime > block.timestamp, "invalid startTime");
        require(_reserve.allocation > 0, "invalid allocation");
        reserves[msg.sender] = _reserve;
        auctionInfo[msg.sender] = daInfo;
    }

    function buyTokens(address _token, uint256 _amount, address _to) external {
        Reserve storage reserve = reserves[_token];
        if (NULL_RESERVE == keccak256(abi.encode(reserve))) revert InvalidToken();
        if (block.timestamp < reserve.startTime) revert NotStarted();
        if (block.timestamp > reserve.endTime) revert Ended();
        if (_amount > reserve.allocation) revert TooMany();

        (, uint256 price) = getPrice(_token);

        reserve.allocation -= _amount.safeCastTo160();
        saleProceeds[_token] += price * _amount;
        IWETH(weth9).transferFrom(msg.sender, address(this), price);
        Minted(_token).mint(_amount, _to);
    }

    function getPrice(address _token) public view virtual returns (uint256 step, uint256 price) {
        uint256 timeSinceStart = block.timestamp - reserves[_token].startTime;
        step = timeSinceStart / auctionInfo[_token].stepLength;
        if (step >= auctionInfo[_token].prices.length) revert InvalidStep();
        price = auctionInfo[_token].prices[step];
    }
}
