# ITicketRedeemer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/7502dc47d919e0bb1248e7f953c914adde69d025/src/interfaces/ITicketRedeemer.sol)

**Inherits:**
[IMinter](/src/interfaces/IMinter.sol/interface.IMinter.md)

**Author:**
fx(hash)

Minter for redeeming FxGenArt721 tokens by burning FxMintTicket721 tokens


## Functions
### redeem

Burns a ticket and mints a new token to the caller


```solidity
function redeem(address _ticket, uint256 _tokenId, bytes calldata _fxParams) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ticket`|`address`|Address of the ticket contract|
|`_tokenId`|`uint256`|ID of the ticket token to burn|
|`_fxParams`|`bytes`|Random sequence of fixed-length bytes used for token input|


### setMintDetails

Sets the mint details for token reserves

*Mint Details: ticket contract address*


```solidity
function setMintDetails(ReserveInfo calldata _reserveInfo, bytes calldata _mintDetails) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserveInfo`|`ReserveInfo`|Reserve information for the token|
|`_mintDetails`|`bytes`|Details of the mint pertaining to the minter|


### tickets

Mapping of FxGenArt721 token address to FxMintTicket721 token address


```solidity
function tickets(address) external view returns (address);
```

## Events
### MintDetailsSet
Event emitted when the mint details are set for a ticket contract


```solidity
event MintDetailsSet(address indexed _ticket, address indexed _token);
```

### Redeemed
Event emitted when a ticket is burned and a new token is minted


```solidity
event Redeemed(address indexed _ticket, uint256 indexed _tokenId, address indexed _owner, address _token);
```

## Errors
### AlreadySet
Error thrown when mint details are already set for a ticket contract


```solidity
error AlreadySet();
```

### InvalidToken
Error thrown when token address is invalid


```solidity
error InvalidToken();
```

### NotAuthorized
Error thrown when the caller is not authorized


```solidity
error NotAuthorized();
```

