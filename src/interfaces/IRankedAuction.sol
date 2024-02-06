// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ReserveInfo} from "src/lib/Structs.sol";

struct SaleInfo {
    uint256 minReserve;
}

struct BidInfo {
    uint96 amount;
    address next;
}

struct LinkedList {
    uint96 size;
    address head;
    uint256 lowest;
    mapping(address => BidInfo) bids;
}

interface IRankedAuction {
    error AlreadyClaimed();
    error InvalidAllocation();
    error InsufficientBalance();
    error InsufficientBid();
    error NotAuthorized();
    error SaleInactive();
    error SaleNotOver();

    event Bid(address indexed _bidder, uint256 indexed _amount, address indexed _head, address _nextBidder);
    event Claim(address indexed _claimer, uint256 indexed _amount);
    event MaxSupplyUpdated(uint256 indexed _previousSupply, uint256 indexed _newSupply);
    event MintDetailsSet(address indexed _token, ReserveInfo indexed _reserve, uint256 _minReserve);
    event Settle(address indexed _owner, uint256 _amount);
    event Withdraw(address indexed _caller, address indexed _to, uint256 indexed _amount);
}
