# IFxIssuerFactory
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/interfaces/IFxIssuerFactory.sol)

**Author:**
fx(hash)

Factory for managing newly deployed FxGenArt721 tokens


## Functions
### createProject

Creates new generative art project


```solidity
function createProject(
    address _owner,
    InitInfo calldata _initInfo,
    ProjectInfo calldata _projectInfo,
    MetadataInfo calldata _metadataInfo,
    MintInfo[] calldata _mintInfo,
    address payable[] calldata _royaltyReceivers,
    uint96[] calldata _basisPoints
) external returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|Address of project owner|
|`_initInfo`|`InitInfo`|Initialization information|
|`_projectInfo`|`ProjectInfo`|Project information|
|`_metadataInfo`|`MetadataInfo`|Metadata information|
|`_mintInfo`|`MintInfo[]`|Array of authorized minter contracts and their reserves|
|`_royaltyReceivers`|`address payable[]`|Array of addresses receiving royalties|
|`_basisPoints`|`uint96[]`|Array of basis points for calculating royalty shares|


### implementation

Returns address of current FxGenArt721 implementation contract


```solidity
function implementation() external view returns (address);
```

### projectId

Returns counter of latest project ID


```solidity
function projectId() external view returns (uint96);
```

### projects

Mapping of project ID to address of FxGenArt721 token contract


```solidity
function projects(uint96) external view returns (address);
```

### roleRegistry

Returns the address of the FxRoleRegistry contract


```solidity
function roleRegistry() external view returns (address);
```

### setImplementation

Sets new FxGenArt721 implementation contract


```solidity
function setImplementation(address _implementation) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_implementation`|`address`|Address of the implementation contract|


## Events
### ImplementationUpdated
Event emitted when the FxGenArt721 implementation contract is updated


```solidity
event ImplementationUpdated(address indexed _owner, address indexed _implementation);
```

### ProjectCreated
Event emitted when a new generative art project is created


```solidity
event ProjectCreated(uint96 indexed _projectId, address indexed _genArtToken, address indexed _owner);
```

## Errors
### InvalidInputSize
Error thrown when input size is zero


```solidity
error InvalidInputSize();
```

### InvalidOwner
Error thrown when owner is zero address


```solidity
error InvalidOwner();
```

### InvalidPrimaryReceiver
Error thrown when primary receiver is zero address


```solidity
error InvalidPrimaryReceiver();
```

### NotAuthorized
Error thrown when caller is not authorized to execute transaction


```solidity
error NotAuthorized();
```

