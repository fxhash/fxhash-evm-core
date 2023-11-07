# ISplitsMain
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/22e6538fd4576a4eee62705cd3e376e2623a19b3/src/interfaces/ISplitsMain.sol)

**Author:**
0xSplits

Interface for SplitsFactory to interact with SplitsMain


## Functions
### createSplit


```solidity
function createSplit(
    address[] calldata accounts,
    uint32[] calldata percentAllocations,
    uint32 distributorFee,
    address controller
) external returns (address);
```

### distributeETH


```solidity
function distributeETH(
    address split,
    address[] calldata accounts,
    uint32[] calldata percentAllocations,
    uint32 distributorFee,
    address distributorAddress
) external;
```

### getHash


```solidity
function getHash(address split) external view returns (bytes32);
```

### predictImmutableSplitAddress


```solidity
function predictImmutableSplitAddress(
    address[] calldata accounts,
    uint32[] calldata percentAllocations,
    uint32 distributorFee
) external view returns (address);
```

### updateSplit


```solidity
function updateSplit(
    address split,
    address[] calldata accounts,
    uint32[] calldata percentAllocations,
    uint32 distributorFee
) external;
```

### withdraw


```solidity
function withdraw(address account, uint256 withdrawETH, address[] calldata tokens) external;
```

