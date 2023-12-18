# AuctionInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/lib/Structs.sol)

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

