# ProjectInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/22e6538fd4576a4eee62705cd3e376e2623a19b3/src/lib/Structs.sol)

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

