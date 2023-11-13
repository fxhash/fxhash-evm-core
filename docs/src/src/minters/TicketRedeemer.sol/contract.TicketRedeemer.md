# TicketRedeemer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/minters/TicketRedeemer.sol)

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
function redeem(address _token, uint256 _ticketId, bytes calldata _fxParams) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`||
|`_ticketId`|`uint256`||
|`_fxParams`|`bytes`|Random sequence of fixed-length bytes used for token input|


### setMintDetails

*Mint Details: ticket contract address*


```solidity
function setMintDetails(ReserveInfo calldata, bytes calldata _mintDetails) external;
```

