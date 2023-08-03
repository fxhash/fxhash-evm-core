// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {wadExp, wadLn, wadMul, unsafeWadMul, toWadUnsafe} from "solmate/src/utils/SignedWadMath.sol";
import {Minted} from "contracts/minters/Minted.sol";
import {IMinter} from "contracts/interfaces/IMinter.sol";

contract DutchAuctionMint is IMinter {
    mapping(address => uint256) public startTimes;
    mapping(address => int256) public decayRates;
    mapping(address => int256) public initialPrices;

    /// @return The price of a token according to DA, scaled by 1e18.
    function getPrice(address _token) public view virtual returns (uint256) {
        int256 timeSinceStart = int256(block.timestamp - startTimes[_token]);
        return uint256(initialPrices[_token] - unsafeWadMul(decayRates[_token], timeSinceStart));
    }

    /*
     * Record the starting price of a token scaled by 1e18.
     * That will be sold along a DA at a fixed linear decay rate starting at some start time
     */
    function setMintDetails(uint256, uint256, uint256, bytes calldata) external {}

    function mint(address _token, address _to) external {
        uint256 price = getPrice(_token);
        Minted(_token).mint(1, _to);
    }
}
