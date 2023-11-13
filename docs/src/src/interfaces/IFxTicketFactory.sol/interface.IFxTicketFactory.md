# IFxTicketFactory
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/interfaces/IFxTicketFactory.sol)

**Author:**
fx(hash)

Factory for managing newly deployed FxMintTicket721 tokens


## Functions
### createTicket

Creates new Generative Art project


```solidity
function createTicket(
    address _owner,
    address _genArt721,
    address _redeemer,
    uint48 _gracePeriod,
    bytes calldata _baseURI,
    MintInfo[] calldata _mintInfo
) external returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|Address of project owner|
|`_genArt721`|`address`|Address of GenArt721 token contract|
|`_redeemer`|`address`|Address of TicketRedeemer minter contract|
|`_gracePeriod`|`uint48`|Duration of time before token enters harberger taxation|
|`_baseURI`|`bytes`|Decoded content identifier of metadata pointer|
|`_mintInfo`|`MintInfo[]`|Array of authorized minter contracts and their reserves|


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

### ImplementationUpdated
Event emitted when the FxMintTicket721 implementation contract is updated


```solidity
event ImplementationUpdated(address indexed _owner, address indexed _implementation);
```

### TicketCreated
Event emitted when new FxMintTicket721 is created


```solidity
event TicketCreated(uint96 indexed _ticketId, address indexed _mintTicket, address indexed _owner);
```

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

### InvalidToken
Error thrown when token contract is zero address


```solidity
error InvalidToken();
```

