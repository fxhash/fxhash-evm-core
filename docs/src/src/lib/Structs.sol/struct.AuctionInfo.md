# AuctionInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/ace7e57339c07ca2ed3c7a6bef724ed3baae64f8/src/lib/Structs.sol)

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

