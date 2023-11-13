# ConfigInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/3196ec292bff15f41085b94e4b488f73ce88013c/src/lib/Structs.sol)

Struct of system config information
- `lockTime` Locked time duration added to mint start time for unverified creators
- `referrerShare` Share amount distributed to accounts referring tokens
- `defaultMetadataURI` Default metadata URI of all revealed tokens


```solidity
struct ConfigInfo {
    uint128 lockTime;
    uint128 referrerShare;
    string defaultMetadataURI;
}
```

