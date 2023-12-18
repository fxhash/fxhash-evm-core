# FxIssuerFactory
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/factories/FxIssuerFactory.sol)

**Inherits:**
[IFxIssuerFactory](/src/interfaces/IFxIssuerFactory.sol/interface.IFxIssuerFactory.md), Ownable, Pausable

**Author:**
fx(hash)

*See the documentation in {IFxIssuerFactory}*


## State Variables
### roleRegistry
Returns the address of the FxRoleRegistry contract


```solidity
address public immutable roleRegistry;
```


### implementation
Returns address of current FxGenArt721 implementation contract


```solidity
address public implementation;
```


### projectId
Returns counter of latest project ID


```solidity
uint96 public projectId;
```


### nonces
Mapping of deployer address to nonce value for precomputing token address


```solidity
mapping(address => uint256) public nonces;
```


### projects
Mapping of project ID to address of FxGenArt721 token contract


```solidity
mapping(uint96 => address) public projects;
```


## Functions
### constructor

*Initializes factory owner, FxRoleRegistry and FxGenArt721 implementation*


```solidity
constructor(address _admin, address _roleRegistry, address _implementation);
```

### createProjectWithTicket

Creates new generative art project with new mint ticket in single transaction


```solidity
function createProjectWithTicket(
    bytes calldata _projectCreationInfo,
    bytes calldata _ticketCreationInfo,
    address _ticketFactory
) external whenNotPaused returns (address genArtToken, address mintTicket);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_projectCreationInfo`|`bytes`|Bytes-encoded data for project creation|
|`_ticketCreationInfo`|`bytes`|Bytes-encoded data for ticket creation|
|`_ticketFactory`|`address`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`genArtToken`|`address`|Address of newly created FxGenArt721 proxy|
|`mintTicket`|`address`|Address of newly created FxMintTicket721 proxy|


### unpause

Enables new FxGenArt721 tokens from being created


```solidity
function unpause() external onlyOwner;
```

### pause

Stops new FxGenArt721 tokens from being created


```solidity
function pause() external onlyOwner;
```

### setImplementation

Sets new FxGenArt721 implementation contract


```solidity
function setImplementation(address _implementation) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_implementation`|`address`|Address of the implementation contract|


### createProject

Creates new generative art project with single parameter


```solidity
function createProject(bytes memory _creationInfo) public returns (address genArt721);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_creationInfo`|`bytes`|Bytes-encoded data for project creation|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`genArt721`|`address`|genArtToken Address of newly created FxGenArt721 proxy|


### createProjectWithParams

Creates new generative art project


```solidity
function createProjectWithParams(
    address _owner,
    InitInfo memory _initInfo,
    ProjectInfo memory _projectInfo,
    MetadataInfo memory _metadataInfo,
    MintInfo[] memory _mintInfo,
    address[] memory _royaltyReceivers,
    uint32[] memory _allocations,
    uint96 _basisPoints
) public whenNotPaused returns (address genArtToken);
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
|`genArtToken`|`address`|Address of newly created FxGenArt721 proxy|


### getTokenAddress

Calculates the CREATE2 address of a new FxGenArt721 proxy


```solidity
function getTokenAddress(address _sender) external view returns (address);
```

### _setImplementation

*Sets the FxGenArt721 implementation contract*


```solidity
function _setImplementation(address _implementation) internal;
```

