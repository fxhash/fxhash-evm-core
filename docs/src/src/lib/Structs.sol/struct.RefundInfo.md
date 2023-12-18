# RefundInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/lib/Structs.sol)

Struct of refund information
- `lastPrice` Price of last sale before selling out
- `minterInfo` Mapping of minter address to struct of minter information


```solidity
struct RefundInfo {
    uint256 lastPrice;
    mapping(address minter => MinterInfo) minterInfo;
}
```

