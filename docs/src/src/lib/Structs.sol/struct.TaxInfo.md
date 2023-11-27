# TaxInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/1ca8488246dda0c8af0201fe562392f87b349fa1/src/lib/Structs.sol)

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

