# MintInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/lib/Structs.sol)

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

