// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IMinter, Reserve} from "contracts/interfaces/IMinter.sol";
import {DutchAuctionMint} from "contracts/minters/DutchAuctionMint.sol";

contract LastPriceDutchAuctionMint is DutchAuctionMint {
    /// add up the persons cumulative mint cost to calculate refunds
    mapping(address => mapping(address => uint256)) public cumulativeMints;
    mapping(address => mapping(address => uint256)) public cumulativeMintCost;
    mapping(address => uint256) public lastPrice;

    /// override mint and if it's the last mint then record the price;

    function refund(address _token, address _who) external {
        uint256 userCost = cumulativeMintCost[_token][_who];
        uint256 numMinted = cumulativeMints[_token][_who];
        delete cumulativeMintCost[_token][_who];
        delete cumulativeMints[_token][_who];
        uint256 refund = userCost - numMinted * lastPrice[_token];
        /// transfer refund
    }
}
