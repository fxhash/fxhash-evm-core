# IFxRoleRegistry
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/interfaces/IFxRoleRegistry.sol)

**Author:**
fx(hash)

Registry for managing AccessControl roles throughout the system


## Functions
### setRoleAdmin

Sets the admin of a new or existing role


```solidity
function setRoleAdmin(bytes32 _role) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_role`|`bytes32`|Hash of the role name|


