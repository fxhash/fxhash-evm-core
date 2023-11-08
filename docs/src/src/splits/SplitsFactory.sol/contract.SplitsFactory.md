# SplitsFactory
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/ace7e57339c07ca2ed3c7a6bef724ed3baae64f8/src/splits/SplitsFactory.sol)

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


### controller
Returns address of 0xSplits controller contract


```solidity
address public controller;
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


### createMutableSplitFor

Creates a new mutable 0xSplits wallet


```solidity
function createMutableSplitFor(address _creator, address[] calldata _accounts, uint32[] calldata _allocations)
    external
    returns (address split);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_creator`|`address`|Address of the creator being added to the split|
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


### setController

Sets the new 0xSplits controller address


```solidity
function setController(address _controller) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_controller`|`address`|Address of the new controller|


### _createMutableSplit

*Creates new mutable 0xSplits wallet*


```solidity
function _createMutableSplit(address _creator, address[] calldata _accounts, uint32[] calldata _allocations)
    internal
    returns (address split);
```

