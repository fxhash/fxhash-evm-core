// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Minter, Reserve} from "contracts/minters/base/Minter.sol";
import {Minted} from "contracts/minters/base/Minted.sol";
import {IWETH} from "contracts/interfaces/IWETH.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";

contract FixedPriceMint is Minter {
    using SafeCastLib for uint256;

    bytes32 internal constant NULL_RESERVE = keccak256(abi.encode(Reserve(0, 0, 0)));
    mapping(address => uint256) public prices;
    mapping(address => Reserve) public reserves;
    mapping(address => uint256) public saleProceeds;

    error InvalidToken();
    error NotStarted();
    error Ended();
    error TooMany();

    function setMintDetails(Reserve calldata _reserve, bytes calldata _mintDetails) external {
        uint256 price = abi.decode(_mintDetails, (uint256));
        prices[msg.sender] = price;
        reserves[msg.sender] = _reserve;
    }

    function buyTokens(address _token, uint256 _amount, address _to) external {
        Reserve storage reserve = reserves[_token];
        if (NULL_RESERVE == keccak256(abi.encode(reserve))) revert InvalidToken();
        if (block.timestamp < reserve.startTime) revert NotStarted();
        if (block.timestamp > reserve.endTime) revert Ended();
        if (_amount > reserve.allocation) revert TooMany();
        uint256 price = _amount * prices[_token];
        reserve.allocation -= _amount.safeCastTo160();
        saleProceeds[_token] += price;
        IWETH(weth9).transferFrom(msg.sender, address(this), price);
        Minted(_token).mint(_amount, _to);
    }

    function withdraw(address _token) external {
        address saleReceiver = Minted(_token).feeReceiver();
        uint256 proceeds = saleProceeds[_token];
        delete saleProceeds[_token];
        IWETH(weth9).transfer(saleReceiver, proceeds);
    }
}
