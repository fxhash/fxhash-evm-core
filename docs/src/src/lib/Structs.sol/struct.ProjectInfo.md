# ProjectInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/lib/Structs.sol)

Struct of project information
- `mintEnabled` Flag inidicating if minting is enabled
- `burnEnabled` Flag inidicating if burning is enabled
- `maxSupply` Maximum supply of tokens
- `inputSize` Maximum input size of fxParams bytes data
- `earliestStartTime` Earliest possible start time for registering minters


```solidity
struct ProjectInfo {
    bool mintEnabled;
    bool burnEnabled;
    uint120 maxSupply;
    uint88 inputSize;
    uint32 earliestStartTime;
}
```

