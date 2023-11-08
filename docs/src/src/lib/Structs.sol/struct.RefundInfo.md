# RefundInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/686a75b6e028ec629d05b5b60596a8ee209b77b5/src/lib/Structs.sol)

Struct of refund information
- `lastPrice` Price of last sale before selling out
- `minterInfo` Mapping of minter address to struct of minter information


```solidity
struct RefundInfo {
    uint256 lastPrice;
    mapping(address minter => MinterInfo) minterInfo;
}
```

