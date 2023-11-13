# ConfigInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/lib/Structs.sol)

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

