# ConfigInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/ace7e57339c07ca2ed3c7a6bef724ed3baae64f8/src/lib/Structs.sol)

Struct of system config information
- `lockTime` Locked time duration added to mint start time for unverified creators
- `referrerShare` Share amount distributed to accounts referring tokens
- `defaultMetadata` Default metadata URI of all unrevealed tokens


```solidity
struct ConfigInfo {
    uint128 lockTime;
    uint128 referrerShare;
    string defaultMetadata;
}
```

