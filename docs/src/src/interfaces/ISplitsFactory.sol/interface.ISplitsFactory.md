# ISplitsFactory
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/686a75b6e028ec629d05b5b60596a8ee209b77b5/src/interfaces/ISplitsFactory.sol)

**Author:**
fx(hash)

Factory for managing newly deployed 0xSplits wallets


## Functions
### controller

Returns address of 0xSplits controller contract


```solidity
function controller() external view returns (address);
```

### createImmutableSplit

Creates a new immutable 0xSplits wallet


```solidity
function createImmutableSplit(address[] calldata _accounts, uint32[] calldata _allocations)
    external
    returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|Array of addresses that participate in the split|
|`_allocations`|`uint32[]`|Array of allocations for each account|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|split Address of the deployed splits contract|


### createMutableSplit

Creates a new mutable 0xSplits wallet


```solidity
function createMutableSplit(address[] calldata _accounts, uint32[] calldata _allocations) external returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|Array of addresses that participate in the split|
|`_allocations`|`uint32[]`|Array of allocations for each account|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|split Address of the deployed splits contract|


### createMutableSplitFor

Creates a new mutable 0xSplits wallet


```solidity
function createMutableSplitFor(address _creator, address[] calldata _accounts, uint32[] calldata _allocations)
    external
    returns (address);
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
|`<none>`|`address`|split Address of the deployed splits contract|


### emitVirtualSplit

Emits a deterministic 0xSplits wallet address


```solidity
function emitVirtualSplit(address[] calldata _accounts, uint32[] calldata _allocations) external returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|Array of addresses that participate in the split|
|`_allocations`|`uint32[]`|Array array of allocations for each account|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|split Address of the deterministic splits wallet|


### setController

Sets the new 0xSplits controller address


```solidity
function setController(address _controller) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_controller`|`address`|Address of the new controller|


### splits

Returns address of the SplitsMain contract


```solidity
function splits() external view returns (address);
```

## Events
### ControllerUpdated
Event emitted when the 0xSplits controller is updated


```solidity
event ControllerUpdated(address indexed _oldController, address indexed _newController);
```

### SplitsInfo
Event emitted to indicate a 0xSplits wallet was created or the deterministic address


```solidity
event SplitsInfo(
    address indexed _split,
    address indexed _controller,
    address[] _accounts,
    uint32[] _allocations,
    uint32 _distributorFee
);
```

## Errors
### InvalidSplit
Error thrown if predicted splits address does not match deployment


```solidity
error InvalidSplit();
```

### SplitsExists
Error thrown if splits wallet was already deployed


```solidity
error SplitsExists();
```

