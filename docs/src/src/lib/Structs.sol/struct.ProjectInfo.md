# ProjectInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/7502dc47d919e0bb1248e7f953c914adde69d025/src/lib/Structs.sol)

Struct of project information
- `onchain` Flag inidicated if project metadata is rendered onchain
- `mintEnabled` Flag inidicating if minting is enabled
- `burnEnabled` Flag inidicating if burning is enabled
- `inputSize` Maximum input size of fxParams bytes data
- `maxSupply` Maximum supply of tokens
- `contractURI` CID hash of collection metadata


```solidity
struct ProjectInfo {
    bool onchain;
    bool mintEnabled;
    bool burnEnabled;
    uint120 maxSupply;
    uint120 inputSize;
    string contractURI;
}
```

