# SplitsFactory
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/1ca8488246dda0c8af0201fe562392f87b349fa1/src/factories/SplitsFactory.sol)

**Inherits:**
[ISplitsFactory](/src/interfaces/ISplitsFactory.sol/interface.ISplitsFactory.md), Ownable

**Author:**
fx(hash)

*See the documentation in {ISplitsFactory}*


## State Variables
### splits
Returns address of the SplitsMain contract


```solidity
address public immutable splits;
```


## Functions
### constructor

*Initializes factory owner and SplitsMain*


```solidity
constructor(address _admin, address _splits);
```

### createImmutableSplit

Creates a new immutable 0xSplits wallet


```solidity
function createImmutableSplit(address[] calldata _accounts, uint32[] calldata _allocations)
    external
    returns (address split);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|Array of addresses that participate in the split|
|`_allocations`|`uint32[]`|Array of allocations for each account|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`split`|`address`|Address of the deployed splits contract|


### createMutableSplit

Creates a new mutable 0xSplits wallet


```solidity
function createMutableSplit(address[] calldata _accounts, uint32[] calldata _allocations)
    external
    returns (address split);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|Array of addresses that participate in the split|
|`_allocations`|`uint32[]`|Array of allocations for each account|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`split`|`address`|Address of the deployed splits contract|


### emitVirtualSplit

Emits a deterministic 0xSplits wallet address


```solidity
function emitVirtualSplit(address[] calldata _accounts, uint32[] calldata _allocations)
    external
    returns (address split);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|Array of addresses that participate in the split|
|`_allocations`|`uint32[]`|Array array of allocations for each account|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`split`|`address`|Address of the deterministic splits wallet|


### _createMutableSplit

*Creates new mutable 0xSplits wallet*


```solidity
function _createMutableSplit(address _controller, address[] calldata _accounts, uint32[] calldata _allocations)
    internal
    returns (address split);
```

