# AuctionInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/686a75b6e028ec629d05b5b60596a8ee209b77b5/src/lib/Structs.sol)

Struct of dutch auction information
- `refunded` Flag indicating if refunds are enabled
- `stepLength` Duration (in seconds) of each auction step
- `prices` Array of prices for each step of the auction


```solidity
struct AuctionInfo {
    bool refunded;
    uint248 stepLength;
    uint256[] prices;
}
```

