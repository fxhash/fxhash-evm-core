// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

struct SaleInfo {
    uint16 startId;
    uint64 supply;
    uint88 startTime;
    uint88 endTime;
    uint96 minReserve;
    address token;
}

struct BidInfo {
    uint96 amount;
    address next;
}

struct LinkedList {
    uint96 size;
    address head;
    mapping(address => BidInfo) bids;
}

interface IRankedAuction {
    event Bid(address indexed _bidder, uint256 indexed _amount, address indexed _head, address _nextBidder);
    event Claim(address indexed _claimer, uint256 indexed _amount);
    event Settle(address indexed _owner, SaleInfo indexed _sale);
}
