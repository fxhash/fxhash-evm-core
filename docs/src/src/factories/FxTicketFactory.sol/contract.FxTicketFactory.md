# FxTicketFactory
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/factories/FxTicketFactory.sol)

**Inherits:**
[IFxTicketFactory](/src/interfaces/IFxTicketFactory.sol/interface.IFxTicketFactory.md), Ownable

**Author:**
fx(hash)

*See the documentation in {IFxTicketFactory}*


## State Variables
### implementation
Returns address of current FxMintTicket721 implementation contract


```solidity
address public implementation;
```


### minGracePeriod
Returns the minimum duration of time before a ticket enters harberger taxation


```solidity
uint48 public minGracePeriod;
```


### ticketId
Returns counter of latest token ID


```solidity
uint48 public ticketId;
```


### nonces
Mapping of deployer address to nonce value for precomputing ticket address


```solidity
mapping(address => uint256) public nonces;
```


### tickets
Mapping of token ID to address of FxMintTicket721 token contract


```solidity
mapping(uint48 => address) public tickets;
```


## Functions
### constructor

*Initializes factory owner, FxMintTicket721 implementation and minimum grace period*


```solidity
constructor(address _admin, address _implementation, uint48 _gracePeriod);
```

### createTicket

Creates new mint ticket


```solidity
function createTicket(bytes calldata _creationInfo) external returns (address mintTicket);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_creationInfo`|`bytes`||


### setImplementation

Sets new FxMintTicket721 implementation contract


```solidity
function setImplementation(address _implementation) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_implementation`|`address`|Address of the implementation contract|


### setMinGracePeriod

Sets the new minimum grace period


```solidity
function setMinGracePeriod(uint48 _gracePeriod) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_gracePeriod`|`uint48`|Minimum time duration before a ticket enters harberger taxation|


### createTicket

Creates new mint ticket


```solidity
function createTicket(
    address _owner,
    address _genArt721,
    address _redeemer,
    address _renderer,
    uint48 _gracePeriod,
    MintInfo[] memory _mintInfo
) public returns (address mintTicket);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|Address of project owner|
|`_genArt721`|`address`|Address of GenArt721 token contract|
|`_redeemer`|`address`|Address of TicketRedeemer minter contract|
|`_renderer`|`address`||
|`_gracePeriod`|`uint48`|Duration of time before token enters harberger taxation|
|`_mintInfo`|`MintInfo[]`|Array of authorized minter contracts and their reserves|


### getTicketAddress

Calculates the CREATE2 address of a new FxMintTicket721 proxy


```solidity
function getTicketAddress(address _sender) external view returns (address);
```

### _setImplementation

*Sets the FxMintTicket721 implementation contract*


```solidity
function _setImplementation(address _implementation) internal;
```

### _setMinGracePeriod

*Sets the minimum grace period of time for when token enters harberger taxation*


```solidity
function _setMinGracePeriod(uint48 _gracePeriod) internal;
```

