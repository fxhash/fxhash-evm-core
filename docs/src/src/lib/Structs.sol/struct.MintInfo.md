# MintInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/3196ec292bff15f41085b94e4b488f73ce88013c/src/lib/Structs.sol)

Struct of mint information
- `minter` Address of the minter contract
- `reserveInfo` Reserve information
- `params` Optional bytes data decoded inside minter


```solidity
struct MintInfo {
    address minter;
    ReserveInfo reserveInfo;
    bytes params;
}
```

