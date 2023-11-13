# IssuerInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/lib/Structs.sol)

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

