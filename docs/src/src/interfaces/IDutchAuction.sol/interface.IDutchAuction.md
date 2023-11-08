# IDutchAuction
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/686a75b6e028ec629d05b5b60596a8ee209b77b5/src/interfaces/IDutchAuction.sol)

**Inherits:**
[IMinter](/src/interfaces/IMinter.sol/interface.IMinter.md)

**Author:**
fx(hash)

Minter for distributing tokens at linear prices over fixed periods of time


## Functions
### auctions

Mapping of token address to reserve ID to reserve information


```solidity
function auctions(address, uint256) external view returns (bool, uint248);
```

### buy

Purchases tokens at a linear price over fixed amount of time


```solidity
function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token being purchased|
|`_reserveId`|`uint256`|ID of the reserve|
|`_amount`|`uint256`|Amount of tokens to purchase|
|`_to`|`address`|Address receiving the purchased tokens|


### buyAllowlist

Purchases tokens through an allowlist at a linear price over fixed amount of time


```solidity
function buyAllowlist(
    address _token,
    uint256 _reserveId,
    address _to,
    uint256[] calldata _indexes,
    bytes32[][] calldata _proofs
) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token being purchased|
|`_reserveId`|`uint256`|ID of the reserve|
|`_to`|`address`|Address receiving the purchased tokens|
|`_indexes`|`uint256[]`|Array of indices containing purchase info inside the BitMap|
|`_proofs`|`bytes32[][]`|Array of merkle proofs used for verifying the purchase|


### buyMintPass

Purchases tokens through a mint pass at a linear price over fixed amount of time


```solidity
function buyMintPass(
    address _token,
    uint256 _reserveId,
    uint256 _amount,
    address _to,
    uint256 _index,
    bytes calldata _signature
) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token being purchased|
|`_reserveId`|`uint256`|ID of the reserve|
|`_amount`|`uint256`|Number of tokens being purchased|
|`_to`|`address`|Address receiving the purchased tokens|
|`_index`|`uint256`|Index of puchase info inside the BitMap|
|`_signature`|`bytes`|Array of merkle proofs used for verifying the purchase|


### getLatestUpdate

Gets the latest timestamp update made to token reserves


```solidity
function getLatestUpdate(address _token) external view returns (uint40);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint40`|Timestamp of latest update|


### getPrice

Gets the current auction price


```solidity
function getPrice(address _token, uint256 _reserveId) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token contract|
|`_reserveId`|`uint256`|ID of the reserve|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|price Price of the token|


### merkleRoots

Mapping of token address to reserve ID to merkle root


```solidity
function merkleRoots(address, uint256) external view returns (bytes32);
```

### numberMinted

Mapping of token address to reserve ID to number of tokens minted


```solidity
function numberMinted(address _token, uint256 _reserveId) external view returns (uint256);
```

### refund

Refunds an auction buyer with their rebate amount


```solidity
function refund(address _token, uint256 _reserveId, address _buyer) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token contract|
|`_reserveId`|`uint256`|ID of the mint|
|`_buyer`|`address`|Address of the buyer receiving the refund|


### refunds

Mapping of token address to reserve ID to refund amount


```solidity
function refunds(address, uint256) external view returns (uint256);
```

### reserves

Mapping of token address to reserve ID to reserve information (allocation, price, max mint)


```solidity
function reserves(address _token, uint256 _reserveId) external view returns (uint64, uint64, uint128);
```

### saleProceeds

Mapping of token address to reserve ID to amount of sale proceeds


```solidity
function saleProceeds(address _token, uint256 _reserveId) external view returns (uint256);
```

### setMintDetails

Sets the mint details for token reserves

*Mint Details: struct of auction information, merkle root, and signer address*


```solidity
function setMintDetails(ReserveInfo calldata _reserveInfo, bytes calldata _mintDetails) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserveInfo`|`ReserveInfo`|Reserve information for the token|
|`_mintDetails`|`bytes`|Details of the mint pertaining to the minter|


### withdraw

Withdraws sale processed of primary sales to receiver


```solidity
function withdraw(address _token, uint256 _reserveId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token contract|
|`_reserveId`|`uint256`|ID of the reserve|


## Events
### MintDetailsSet
Event emitted when the mint details for a Dutch auction are set


```solidity
event MintDetailsSet(
    address indexed _token, uint256 indexed _reserveId, ReserveInfo _reserveInfo, AuctionInfo _auctionInfo
);
```

### Purchase
Event emitted when a purchase is made during the auction


```solidity
event Purchase(
    address indexed _token,
    uint256 indexed _reserveId,
    address indexed _buyer,
    address _to,
    uint256 _amount,
    uint256 _price
);
```

### RefundClaimed
Event emitted when a refund is claimed by a buyer


```solidity
event RefundClaimed(address indexed _token, uint256 indexed _reserveId, address indexed _buyer, uint256 _refundAmount);
```

### Withdrawn
Event emitted when the sale proceeds are withdrawn


```solidity
event Withdrawn(address indexed _token, uint256 indexed _reserveId, address indexed _creator, uint256 _proceeds);
```

## Errors
### AddressZero
Error thrown when receiver is zero address


```solidity
error AddressZero();
```

### Ended
Error thrown when the auction has already ended


```solidity
error Ended();
```

### InsufficientFunds
Error thrown when no funds available to withdraw


```solidity
error InsufficientFunds();
```

### InsufficientPrice
Error thrown when the price is insufficient


```solidity
error InsufficientPrice();
```

### InvalidAllocation
Error thrown when the allocation amount is zero


```solidity
error InvalidAllocation();
```

### InvalidAmount
Error thrown when the purchase amount is zero


```solidity
error InvalidAmount();
```

### InvalidPayment
Error thrown when payment does not equal price


```solidity
error InvalidPayment();
```

### InvalidPrice
Error thrown when the price is zero


```solidity
error InvalidPrice();
```

### InvalidPriceCurve
Error thrown when the passing a price curve with less than 2 points


```solidity
error InvalidPriceCurve();
```

### InvalidReserve
Error thrown when a reserve does not exist


```solidity
error InvalidReserve();
```

### InvalidStep
Error thrown when the step length is not equally divisible by the auction duration


```solidity
error InvalidStep();
```

### InvalidToken
Error thrown when the token is address zero


```solidity
error InvalidToken();
```

### NoAllowlist
Error thrown when buying through allowlist and no allowlist exists


```solidity
error NoAllowlist();
```

### NoPublicMint
Error thrown when calling buy when either an allowlist or signer exists


```solidity
error NoPublicMint();
```

### NoRefund
Error thrown when there is no refund available


```solidity
error NoRefund();
```

### NoSigningAuthority
Error thrown when buy with a mint pass and no signing authority exists


```solidity
error NoSigningAuthority();
```

### NotEnded
Error thrown if auction has not ended


```solidity
error NotEnded();
```

### NotStarted
Error thrown when the auction has not started


```solidity
error NotStarted();
```

### OnlyAuthorityOrAllowlist
Error thrown when setting both an allowlist and mint signer


```solidity
error OnlyAuthorityOrAllowlist();
```

### PricesOutOfOrder
Error thrown when the prices are out of order


```solidity
error PricesOutOfOrder();
```

