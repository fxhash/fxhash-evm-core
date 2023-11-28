# AuctionInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/lib/Structs.sol)

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

