# MetadataInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/lib/Structs.sol)

Struct of metadata information
- `baseURI` Decoded URI of content identifier
- `onchainPointer` Address of bytes-encoded data rendered onchain


```solidity
struct MetadataInfo {
    bytes baseURI;
    address onchainPointer;
}
```

