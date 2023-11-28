# TicketRedeemer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/minters/TicketRedeemer.sol)

**Inherits:**
[ITicketRedeemer](/src/interfaces/ITicketRedeemer.sol/interface.ITicketRedeemer.md)

**Author:**
fx(hash)

*See the documentation in {ITicketRedeemer}*


## State Variables
### tickets
Mapping of FxGenArt721 token address to FxMintTicket721 token address


```solidity
mapping(address => address) public tickets;
```


## Functions
### redeem

Burns a ticket and mints a new token to the caller


```solidity
function redeem(address _token, address _to, uint256 _ticketId, bytes calldata _fxParams) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`||
|`_to`|`address`|Address of token receiver|
|`_ticketId`|`uint256`||
|`_fxParams`|`bytes`|Random sequence of fixed-length bytes used for token input|


### setMintDetails

*Mint Details: ticket contract address*


```solidity
function setMintDetails(ReserveInfo calldata, bytes calldata _mintDetails) external;
```

