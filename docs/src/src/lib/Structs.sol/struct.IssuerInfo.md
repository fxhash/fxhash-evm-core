# IssuerInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/lib/Structs.sol)

Struct of issuer information
- `primaryReceiver` Address of splitter contract receiving primary sales
- `projectInfo` Project information
- `activeMinters` Array of authorized minter contracts used for enumeration
- `minters` Mapping of minter contract to authorization status


```solidity
struct IssuerInfo {
    address primaryReceiver;
    ProjectInfo projectInfo;
    address[] activeMinters;
    mapping(address => uint8) minters;
}
```

