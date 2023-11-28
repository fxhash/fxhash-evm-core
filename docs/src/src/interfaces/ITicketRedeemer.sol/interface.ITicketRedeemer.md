# ITicketRedeemer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/interfaces/ITicketRedeemer.sol)

**Inherits:**
[IMinter](/src/interfaces/IMinter.sol/interface.IMinter.md)

**Author:**
fx(hash)

Minter for redeeming FxGenArt721 tokens by burning FxMintTicket721 tokens


## Functions
### redeem

Burns a ticket and mints a new token to the caller


```solidity
function redeem(address _ticket, address _to, uint256 _tokenId, bytes calldata _fxParams) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ticket`|`address`|Address of the ticket contract|
|`_to`|`address`|Address of token receiver|
|`_tokenId`|`uint256`|ID of the ticket being burned|
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

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ticket`|`address`|Address of the ticket contract|
|`_token`|`address`|Address of the token contract that can be redeemed through the ticket|

### Redeemed
Event emitted when a ticket is burned and a new token is minted


```solidity
event Redeemed(address indexed _ticket, uint256 indexed _tokenId, address indexed _owner, address _token);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ticket`|`address`|Address of the ticket contract|
|`_tokenId`|`uint256`|ID of the token being burned|
|`_owner`|`address`|Address of the owner receiving the token|
|`_token`|`address`|Address of the token being minted|

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

### ZeroAddress
Error thrown when receiver is zero address


```solidity
error ZeroAddress();
```

