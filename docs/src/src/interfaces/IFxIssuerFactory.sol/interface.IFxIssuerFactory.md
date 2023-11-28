# IFxIssuerFactory
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/interfaces/IFxIssuerFactory.sol)

**Author:**
fx(hash)

Factory for managing newly deployed FxGenArt721 tokens


## Functions
### createProject

Creates new generative art project


```solidity
function createProject(
    address _owner,
    InitInfo memory _initInfo,
    ProjectInfo memory _projectInfo,
    MetadataInfo memory _metadataInfo,
    MintInfo[] memory _mintInfo,
    address[] memory _royaltyReceivers,
    uint32[] memory _allocations,
    uint96 _basisPoints
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
|`_royaltyReceivers`|`address[]`|Array of addresses receiving royalties|
|`_allocations`|`uint32[]`|Array of allocation amounts for calculating royalty shares|
|`_basisPoints`|`uint96`|Total allocation scalar for calculating royalty shares|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|genArtToken Address of newly created FxGenArt721 proxy|


### createProject

Creates new generative art project with single parameter


```solidity
function createProject(bytes memory _creationInfo) external returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_creationInfo`|`bytes`|Bytes-encoded data for project creation|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|genArtToken Address of newly created FxGenArt721 proxy|


### createProject

Creates new generative art project with new mint ticket in single transaction


```solidity
function createProject(bytes calldata _projectCreationInfo, bytes calldata _ticketCreationInfo, address _tickeFactory)
    external
    returns (address, address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_projectCreationInfo`|`bytes`|Bytes-encoded data for project creation|
|`_ticketCreationInfo`|`bytes`|Bytes-encoded data for ticket creation|
|`_tickeFactory`|`address`|Address of FxTicketFactory contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|genArtToken Address of newly created FxGenArt721 proxy|
|`<none>`|`address`|mintTicket Address of newly created FxMintTicket721 proxy|


### getTokenAddress

Calculates the CREATE2 address of a new FxGenArt721 proxy


```solidity
function getTokenAddress(address _sender) external view returns (address);
```

### implementation

Returns address of current FxGenArt721 implementation contract


```solidity
function implementation() external view returns (address);
```

### nonces

Mapping of deployer address to nonce value for precomputing token address


```solidity
function nonces(address _deployer) external view returns (uint256);
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

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|Address of the factory owner|
|`_implementation`|`address`|Address of the new FxGenArt721 implementation contract|

### ProjectCreated
Event emitted when a new generative art project is created


```solidity
event ProjectCreated(uint96 indexed _projectId, address indexed _genArtToken, address indexed _owner);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_projectId`|`uint96`|ID of the project|
|`_genArtToken`|`address`|Address of newly deployed FxGenArt721 token contract|
|`_owner`|`address`|Address of project owner|

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

