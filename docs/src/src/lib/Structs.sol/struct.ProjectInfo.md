# ProjectInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/3196ec292bff15f41085b94e4b488f73ce88013c/src/lib/Structs.sol)

Struct of project information
- `mintEnabled` Flag inidicating if minting is enabled
- `burnEnabled` Flag inidicating if burning is enabled
- `inputSize` Maximum input size of fxParams bytes data
- `maxSupply` Maximum supply of tokens


```solidity
struct ProjectInfo {
    bool mintEnabled;
    bool burnEnabled;
    uint120 maxSupply;
    uint120 inputSize;
}
```

