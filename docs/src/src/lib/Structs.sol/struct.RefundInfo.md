# RefundInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/lib/Structs.sol)

Struct of refund information
- `lastPrice` Price of last sale before selling out
- `minterInfo` Mapping of minter address to struct of minter information


```solidity
struct RefundInfo {
    uint256 lastPrice;
    mapping(address minter => MinterInfo) minterInfo;
}
```

