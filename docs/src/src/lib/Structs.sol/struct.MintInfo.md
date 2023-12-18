# MintInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/lib/Structs.sol)

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

