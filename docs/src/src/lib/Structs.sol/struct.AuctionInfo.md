# AuctionInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/3196ec292bff15f41085b94e4b488f73ce88013c/src/lib/Structs.sol)

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

