# SplitsController
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/22e6538fd4576a4eee62705cd3e376e2623a19b3/src/splits/SplitsController.sol)

**Inherits:**
[ISplitsController](/src/interfaces/ISplitsController.sol/interface.ISplitsController.md), Ownable

**Author:**
fx(hash)

Extension for controlling 0xSplits wallets deployed through SplitsFactory


## State Variables
### isFxHash
Mapping of splits wallet address to flag indicating if wallet is fxhash


```solidity
mapping(address => bool) public isFxHash;
```


### splitCreators
Mapping of splits wallet address to address of creator


```solidity
mapping(address => address) public splitCreators;
```


### splitsFactory
Address of the SplitsFactory contract


```solidity
address public splitsFactory;
```


### splitsMain
Address of the SplitsMain contract


```solidity
address public splitsMain;
```


## Functions
### constructor

*Initializes controller owner, SplitsMain, and FxSplitsFactory*


```solidity
constructor(address _splitsMain, address _splitsFactory, address _owner);
```

### addCreator

Adds a new creator to the split


```solidity
function addCreator(address _split, address _creator) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_split`|`address`|Address of the splits wallet|
|`_creator`|`address`|Address of the new creator|


### transferAllocation

Transfers allocation amount of the split to given account


```solidity
function transferAllocation(address _to, address _split, address[] memory _accounts, uint32[] memory _allocations)
    external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address of the receiver|
|`_split`|`address`|Address of the splits wallet|
|`_accounts`|`address[]`|Array of addresses included in the splits|
|`_allocations`|`uint32[]`|Array of allocation amounts for each account|


### transferAllocationFrom

Transfers allocation amount of the split from given account to given account


```solidity
function transferAllocationFrom(
    address _from,
    address _to,
    address _split,
    address[] memory _accounts,
    uint32[] memory _allocations
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|Address of the sender|
|`_to`|`address`|Address of the receiver|
|`_split`|`address`|Address of the splits wallet|
|`_accounts`|`address[]`|Array of addresses included in the splits|
|`_allocations`|`uint32[]`|Array of allocation amounts for each account|


### updateFxHash

Updates the active flag status of an fxhash account


```solidity
function updateFxHash(address _fxHash, bool _active) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_fxHash`|`address`|Address of the fxhash account|
|`_active`|`bool`|Flag indicating active status|


### _transferAllocationFrom

*Transfers allocation of split from given account to given account*


```solidity
function _transferAllocationFrom(
    address _from,
    address _to,
    address _split,
    address[] memory _accounts,
    uint32[] memory _allocations
) internal;
```

### _hashSplit

*Returns the computed hash of a splits wallet*


```solidity
function _hashSplit(address[] memory _accounts, uint32[] memory _percentAllocations) internal pure returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|Unique list of ordered addresses with ownership in the split|
|`_percentAllocations`|`uint32[]`|Percent allocations associated with each address|


### _sort

*Sorts arrays of accounts in descending order and their associated allocations*


```solidity
function _sort(uint256 _begin, uint256 _last, address[] memory _accounts, uint32[] memory _allocations)
    internal
    pure
    returns (address[] memory, uint32[] memory);
```

### _swap

*Swaps two elements in the arrays*


```solidity
function _swap(uint256 i, uint256 j, address[] memory _accounts, uint32[] memory _allocations) internal pure;
```

