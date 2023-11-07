# TaxInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/22e6538fd4576a4eee62705cd3e376e2623a19b3/src/lib/Structs.sol)

Struct of tax information
- `gracePeriod` Timestamp of period before token entering harberger taxation
- `foreclosureTime` Timestamp of token foreclosure
- `currentPrice` Current ether price of token
- `depositAmount` Total amount of taxes deposited


```solidity
struct TaxInfo {
    uint48 gracePeriod;
    uint48 foreclosureTime;
    uint80 currentPrice;
    uint80 depositAmount;
}
```

