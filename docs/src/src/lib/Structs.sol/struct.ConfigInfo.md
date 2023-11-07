# ConfigInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/22e6538fd4576a4eee62705cd3e376e2623a19b3/src/lib/Structs.sol)

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

