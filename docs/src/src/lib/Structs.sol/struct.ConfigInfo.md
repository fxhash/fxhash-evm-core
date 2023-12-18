# ConfigInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/lib/Structs.sol)

Struct of system config information
- `feeReceiver` Address receiving platform fees
- `primaryFeeAllocation` Amount of basis points allocated to calculate platform fees on primary sale proceeds
- `secondaryFeeAllocation` Amount of basis points allocated to calculate platform fees on royalty payments
- `lockTime` Locked time duration added to mint start time for unverified creators
- `referrerShare` Share amount distributed to accounts referring tokens
- `defaultMetadataURI` Default base URI of token metadata
- `externalURI` External URI for displaying tokens


```solidity
struct ConfigInfo {
    address feeReceiver;
    uint32 primaryFeeAllocation;
    uint32 secondaryFeeAllocation;
    uint32 lockTime;
    uint64 referrerShare;
    string defaultMetadataURI;
    string externalURI;
}
```

