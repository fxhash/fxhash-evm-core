# IFxTicketFactory
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/1ca8488246dda0c8af0201fe562392f87b349fa1/src/interfaces/IFxTicketFactory.sol)

**Author:**
fx(hash)

Factory for managing newly deployed FxMintTicket721 tokens


## Functions
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
) external returns (address);
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


### createTicket

Creates new mint ticket for new generative art project in single transaction


```solidity
function createTicket(bytes calldata _creationInfo) external returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_creationInfo`|`bytes`|Bytes-encoded data for ticket creation|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|mintTicket Address of newly created FxMintTicket721 proxy|


### getTicketAddress

Calculates the CREATE2 address of a new FxMintTicket721 proxy


```solidity
function getTicketAddress(address _sender) external view returns (address);
```

### implementation

Returns address of current FxMintTicket721 implementation contract


```solidity
function implementation() external view returns (address);
```

### minGracePeriod

Returns the minimum duration of time before a ticket enters harberger taxation


```solidity
function minGracePeriod() external view returns (uint48);
```

### nonces

Mapping of deployer address to nonce value for precomputing ticket address


```solidity
function nonces(address _deployer) external view returns (uint256);
```

### setMinGracePeriod

Sets the new minimum grace period


```solidity
function setMinGracePeriod(uint48 _gracePeriod) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_gracePeriod`|`uint48`|Minimum time duration before a ticket enters harberger taxation|


### setImplementation

Sets new FxMintTicket721 implementation contract


```solidity
function setImplementation(address _implementation) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_implementation`|`address`|Address of the implementation contract|


### ticketId

Returns counter of latest token ID


```solidity
function ticketId() external view returns (uint48);
```

### tickets

Mapping of token ID to address of FxMintTicket721 token contract


```solidity
function tickets(uint48 _ticketId) external view returns (address);
```

## Events
### GracePeriodUpdated
Event emitted when the minimum grace period is updated


```solidity
event GracePeriodUpdated(address indexed _owner, uint48 indexed _gracePeriod);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|Address of the factory owner|
|`_gracePeriod`|`uint48`|Time duration of the new grace period|

### ImplementationUpdated
Event emitted when the FxMintTicket721 implementation contract is updated


```solidity
event ImplementationUpdated(address indexed _owner, address indexed _implementation);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|Address of the factory owner|
|`_implementation`|`address`|Address of the new FxMintTicket721 implementation contract|

### TicketCreated
Event emitted when new FxMintTicket721 is created


```solidity
event TicketCreated(uint96 indexed _ticketId, address indexed _mintTicket, address indexed _owner);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ticketId`|`uint96`|ID of the ticket contract|
|`_mintTicket`|`address`|Address of newly deployed FxMintTicket721 token contract|
|`_owner`|`address`|Address of ticket owner|

## Errors
### InvalidGracePeriod
Error thrown when grace period is less than minimum requirement of one day


```solidity
error InvalidGracePeriod();
```

### InvalidOwner
Error thrown when owner is zero address


```solidity
error InvalidOwner();
```

### InvalidRedeemer
Error thrown when redeemer contract is zero address


```solidity
error InvalidRedeemer();
```

### InvalidRenderer
Error thrown when renderer contract is zero address


```solidity
error InvalidRenderer();
```

### InvalidToken
Error thrown when token contract is zero address


```solidity
error InvalidToken();
```

