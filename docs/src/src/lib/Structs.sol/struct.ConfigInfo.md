# ConfigInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/lib/Structs.sol)

Struct of system config information
- `feeReceiver` Address receiving platform fees
- `primaryFeeAllocation` Amount of basis points allocated to calculate platform fees on primary sale proceeds
- `secondaryFeeAllocation` Amount of basis points allocated to calculate platform fees on royalty payments
- `lockTime` Locked time duration added to mint start time for unverified creators
- `referrerShare` Share amount distributed to accounts referring tokens
- `defaultMetadataURI` Default metadata URI of all revealed tokens


```solidity
struct ConfigInfo {
    address feeReceiver;
    uint32 primaryFeeAllocation;
    uint32 secondaryFeeAllocation;
    uint32 lockTime;
    uint64 referrerShare;
    string defaultMetadataURI;
}
```

