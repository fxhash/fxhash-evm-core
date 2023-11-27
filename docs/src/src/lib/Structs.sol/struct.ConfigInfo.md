# ConfigInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/1ca8488246dda0c8af0201fe562392f87b349fa1/src/lib/Structs.sol)

Struct of system config information
- `feeReceiver` Address receiving platform fees
- `feeAllocation` Amount of basis points allocated to calculate platform fees
- `lockTime` Locked time duration added to mint start time for unverified creators
- `referrerShare` Share amount distributed to accounts referring tokens
- `defaultMetadataURI` Default metadata URI of all revealed tokens


```solidity
struct ConfigInfo {
    address feeReceiver;
    uint32 feeAllocation;
    uint64 lockTime;
    uint64 referrerShare;
    string defaultMetadataURI;
}
```

