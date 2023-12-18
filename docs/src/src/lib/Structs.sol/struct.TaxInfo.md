# TaxInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/lib/Structs.sol)

Struct of tax information
- `startTime` Timestamp of when harberger taxation begins
- `foreclosureTime` Timestamp of token foreclosure
- `currentPrice` Current listing price of token
- `depositAmount` Total amount of taxes deposited


```solidity
struct TaxInfo {
    uint48 startTime;
    uint48 foreclosureTime;
    uint80 currentPrice;
    uint80 depositAmount;
}
```

