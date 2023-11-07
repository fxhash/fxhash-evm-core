# IFxRoleRegistry
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/22e6538fd4576a4eee62705cd3e376e2623a19b3/src/interfaces/IFxRoleRegistry.sol)

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


