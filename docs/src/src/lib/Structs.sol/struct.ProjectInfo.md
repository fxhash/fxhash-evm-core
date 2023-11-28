# ProjectInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/lib/Structs.sol)

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

