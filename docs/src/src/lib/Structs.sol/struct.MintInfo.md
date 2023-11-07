# MintInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/22e6538fd4576a4eee62705cd3e376e2623a19b3/src/lib/Structs.sol)

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

