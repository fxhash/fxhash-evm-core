# FxContractRegistry
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/3196ec292bff15f41085b94e4b488f73ce88013c/src/registries/FxContractRegistry.sol)

**Inherits:**
[IFxContractRegistry](/src/interfaces/IFxContractRegistry.sol/interface.IFxContractRegistry.md), Ownable

**Author:**
fx(hash)

*See the documentation in {IFxContractRegistry}*


## State Variables
### configInfo
Returns the system config information (lock time, referrer share, default metadata)


```solidity
ConfigInfo public configInfo;
```


### contracts
Mapping of hashed contract name to contract address


```solidity
mapping(bytes32 => address) public contracts;
```


## Functions
### constructor

*Initializes registry owner and system config information*


```solidity
constructor(address _admin, ConfigInfo memory _configInfo) Ownable;
```

### register

Registers deployed contract addresses based on hashed value of name


```solidity
function register(string[] calldata _names, address[] calldata _contracts) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_names`|`string[]`|Array of contract names|
|`_contracts`|`address[]`|Array of contract addresses|


### setConfig

Sets the system config information


```solidity
function setConfig(ConfigInfo calldata _configInfo) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_configInfo`|`ConfigInfo`|Config information (lock time, referrer share, default metadata)|


### _setConfigInfo

*Sets the system config information*


```solidity
function _setConfigInfo(ConfigInfo memory _configInfo) internal;
```

