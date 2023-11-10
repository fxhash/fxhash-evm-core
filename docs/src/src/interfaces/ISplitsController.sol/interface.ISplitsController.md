# ISplitsController
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/ace7e57339c07ca2ed3c7a6bef724ed3baae64f8/src/interfaces/ISplitsController.sol)

**Author:**
fx(hash)

Interface for SplitsFactory and Recipients to interact with SplitsControllers


## Functions
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
function updateFxHash(address _fxHash, bool _active) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_fxHash`|`address`|Address of the fxhash account|
|`_active`|`bool`|Flag indicating active status|


### isFxHash

Mapping of splits wallet address to flag indicating if wallet is fxhash


```solidity
function isFxHash(address _account) external view returns (bool);
```

### splitCreators

Mapping of splits wallet address to address of creator


```solidity
function splitCreators(address _split) external view returns (address);
```

### splitsFactory

Address of the SplitsFactory contract


```solidity
function splitsFactory() external view returns (address);
```

### splitsMain

Address of the SplitsMain contract


```solidity
function splitsMain() external view returns (address);
```

## Errors
### AccountNotFound
Error thrown when account is not in list of accounts


```solidity
error AccountNotFound();
```

### AccountsIdentical
Error thrown when accounts are identical


```solidity
error AccountsIdentical();
```

### UnauthorizedTransfer
Error thrown when caller is not fxhash


```solidity
error UnauthorizedTransfer();
```

### NotAuthorized
Error thrown when caller is not authorized to execute transaction


```solidity
error NotAuthorized();
```

### NotSplitsFactory
Error thrown when caller is not the splitsFactory


```solidity
error NotSplitsFactory();
```

### NotValidSplitHash
Error thrown when the split hash is invalid


```solidity
error NotValidSplitHash();
```

