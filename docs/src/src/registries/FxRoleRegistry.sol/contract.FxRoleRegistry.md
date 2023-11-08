# FxRoleRegistry
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/ace7e57339c07ca2ed3c7a6bef724ed3baae64f8/src/registries/FxRoleRegistry.sol)

**Inherits:**
AccessControl, [IFxRoleRegistry](/src/interfaces/IFxRoleRegistry.sol/interface.IFxRoleRegistry.md)

**Author:**
fx(hash)

*See the documentation in {IFxRoleRegistry}*


## Functions
### constructor

*Initializes registry owner and role admins*


```solidity
constructor(address _admin);
```

### setRoleAdmin

Sets the admin of a new or existing role


```solidity
function setRoleAdmin(bytes32 _role) external onlyRole(ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_role`|`bytes32`|Hash of the role name|


