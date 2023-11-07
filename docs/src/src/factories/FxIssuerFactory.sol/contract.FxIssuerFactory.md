# FxIssuerFactory
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/7502dc47d919e0bb1248e7f953c914adde69d025/src/factories/FxIssuerFactory.sol)

**Inherits:**
[IFxIssuerFactory](/src/interfaces/IFxIssuerFactory.sol/interface.IFxIssuerFactory.md), Ownable

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


### projects
Mapping of project ID to address of FxGenArt721 token contract


```solidity
mapping(uint96 => address) public projects;
```


## Functions
### isBanned

*Modifier for checking if user is banned from system*


```solidity
modifier isBanned(address _user);
```

### constructor

*Initializes factory owner, FxRoleRegistry and FxGenArt721 implementation*


```solidity
constructor(address _admin, address _roleRegistry, address _implementation);
```

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
) external isBanned(_owner) returns (address genArtToken);
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


### setImplementation

Sets new FxGenArt721 implementation contract


```solidity
function setImplementation(address _implementation) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_implementation`|`address`|Address of the implementation contract|


### _setImplementation

*Sets the FxGenArt721 implementation contract*


```solidity
function _setImplementation(address _implementation) internal;
```

