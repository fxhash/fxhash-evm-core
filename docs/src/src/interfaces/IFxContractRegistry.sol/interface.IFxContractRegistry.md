# IFxContractRegistry
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/7502dc47d919e0bb1248e7f953c914adde69d025/src/interfaces/IFxContractRegistry.sol)

**Author:**
fx(hash)

Registry for managing fxhash smart contracts


## Functions
### configInfo

Returns the system config information (lock time, referrer share, default metadata)


```solidity
function configInfo() external view returns (uint128, uint128, string memory);
```

### contracts

Mapping of hashed contract name to contract address


```solidity
function contracts(bytes32) external view returns (address);
```

### register

Registers deployed contract addresses based on hashed value of name


```solidity
function register(string[] calldata _names, address[] calldata _contracts) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_names`|`string[]`|Array of contract names|
|`_contracts`|`address[]`|Array of contract addresses|


### setConfig

Sets the system config information


```solidity
function setConfig(ConfigInfo calldata _configInfo) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_configInfo`|`ConfigInfo`|Config information (lock time, referrer share, default metadata)|


## Events
### ContractRegistered
Event emitted when contract gets registered


```solidity
event ContractRegistered(string indexed _contractName, bytes32 indexed _hashedName, address indexed _contractAddr);
```

### ConfigUpdated
Event emitted when the config information is updated


```solidity
event ConfigUpdated(address indexed _owner, ConfigInfo _configInfo);
```

## Errors
### LengthMismatch
Error thrown when array lengths do not match


```solidity
error LengthMismatch();
```

### LengthZero
Error thrown when array length is zero


```solidity
error LengthZero();
```

