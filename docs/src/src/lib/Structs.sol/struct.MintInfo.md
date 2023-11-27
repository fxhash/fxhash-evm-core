# MintInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/1ca8488246dda0c8af0201fe562392f87b349fa1/src/lib/Structs.sol)

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

