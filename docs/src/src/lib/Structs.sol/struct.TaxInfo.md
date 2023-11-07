# TaxInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/7502dc47d919e0bb1248e7f953c914adde69d025/src/lib/Structs.sol)

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

