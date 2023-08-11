// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IMinter} from "src/interfaces/IMinter.sol";
import {Minted} from "src/minters/base/Minted.sol";
import {DutchAuctionMint} from "src/minters/DutchAuctionMint.sol";

/// Should refactor the merkle mint first into abstract and inherit

contract DutchAuctionMerkleMint is DutchAuctionMint {}
