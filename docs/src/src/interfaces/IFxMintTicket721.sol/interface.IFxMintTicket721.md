# IFxMintTicket721
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/7502dc47d919e0bb1248e7f953c914adde69d025/src/interfaces/IFxMintTicket721.sol)

**Inherits:**
[IToken](/src/interfaces/IToken.sol/interface.IToken.md)

**Author:**
fx(hash)

ERC-721 token for mint tickets used to redeem FxGenArt721 tokens


## Functions
### activeMinters

Returns the list of active minters


```solidity
function activeMinters(uint256) external view returns (address);
```

### baseURI

Returns the URI of the token metadata


```solidity
function baseURI() external view returns (string memory);
```

### burn

Burns token ID from the circulating supply


```solidity
function burn(uint256 _tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|


### claim

Claims token at current price and sets new price of token with initial deposit amount


```solidity
function claim(uint256 _tokenId, uint80 _newPrice) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_newPrice`|`uint80`|New listing price of token|


### contractRegistry

Returns the address of the FxContractRegistry contract


```solidity
function contractRegistry() external view returns (address);
```

### deposit

Deposits taxes for given token


```solidity
function deposit(uint256 _tokenId) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|


### initialize

Initializes new generative art project


```solidity
function initialize(
    address _owner,
    address _genArt721,
    address _redeemer,
    uint48 _gracePeriod,
    string calldata _baseURI,
    MintInfo[] calldata _mintInfo
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|Address of contract owner|
|`_genArt721`|`address`|Address of GenArt721 token contract|
|`_redeemer`|`address`|Address of TicketRedeemer minter contract|
|`_gracePeriod`|`uint48`|Period time before token enters harberger taxation|
|`_baseURI`|`string`|Base URI of the token metadata|
|`_mintInfo`|`MintInfo[]`|Array of authorized minter contracts and their reserves|


### isForeclosed

Checks if token is foreclosed


```solidity
function isForeclosed(uint256 _tokenId) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Status of foreclosure|


### genArt721

Returns address of the FxGenArt721 token contract


```solidity
function genArt721() external view returns (address);
```

### getAuctionPrice

Gets the current auction price of the token


```solidity
function getAuctionPrice(uint256 _currentPrice, uint256 _foreclosureTime) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_currentPrice`|`uint256`|Listing price of the token|
|`_foreclosureTime`|`uint256`|Timestamp of the foreclosure|


### getBalance

Gets the pending balance amount available for a given wallet


```solidity
function getBalance(address _account) external view returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|Address of the wallet|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint128`|Balance amount available for withdrawal|


### getDailyTax

Gets the daily tax amount based on current price


```solidity
function getDailyTax(uint256 _currentPrice) external pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_currentPrice`|`uint256`|Current listing price|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Daily tax amount|


### getExcessTax

Gets the excess amount of taxes paid


```solidity
function getExcessTax(uint256 _totalDeposit, uint256 _dailyTax) external pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_totalDeposit`|`uint256`|Total amount of taxes deposited|
|`_dailyTax`|`uint256`|Daily tax amount based on current price|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Excess amount of taxes|


### getForeclosureTime

Gets the new foreclosure timestamp


```solidity
function getForeclosureTime(uint256 _dailyTax, uint256 _foreclosureTime, uint256 _taxPayment)
    external
    pure
    returns (uint48);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dailyTax`|`uint256`|Daily tax amount based on current price|
|`_foreclosureTime`|`uint256`|Timestamp of current foreclosure|
|`_taxPayment`|`uint256`|Amount of taxes being deposited|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint48`|Timestamp of new foreclosure|


### getRemainingDeposit

Gets the remaining amount of taxes to be deposited


```solidity
function getRemainingDeposit(uint256 _dailyTax, uint256 _foreclosureTime, uint256 _depositAmount)
    external
    view
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dailyTax`|`uint256`|Daily tax amount based on current price|
|`_foreclosureTime`|`uint256`|Timestamp of current foreclosure|
|`_depositAmount`|`uint256`|Total amount of taxes deposited|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Remainig deposit amount|


### getTaxDuration

Gets the total duration of time covered


```solidity
function getTaxDuration(uint256 _taxPayment, uint256 _dailyTax) external pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_taxPayment`|`uint256`|Amount of taxes being deposited|
|`_dailyTax`|`uint256`|Daily tax amount based on current price|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Total time duration|


### gracePeriod

Returns default grace period of time for each token


```solidity
function gracePeriod() external view returns (uint48);
```

### mint

Mints arbitrary number of tokens

*Only callable by registered minter contracts*


```solidity
function mint(address _to, uint256 _amount, uint256 _payment) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address receiving tokens|
|`_amount`|`uint256`|Number of tokens being minted|
|`_payment`|`uint256`|Total payment amount of the transaction|


### minters

Returns the active status of a registered minter contract


```solidity
function minters(address) external view returns (uint8);
```

### pause

Pauses all function executions where modifier is set


```solidity
function pause() external;
```

### redeemer

Returns the address of the TickeRedeemer contract


```solidity
function redeemer() external view returns (address);
```

### registerMinters

Registers minter contracts with resereve info


```solidity
function registerMinters(MintInfo[] calldata _mintInfo) external;
```

### roleRegistry

Returns the address of the FxRoleRegistry contract


```solidity
function roleRegistry() external view returns (address);
```

### setBaseURI

Sets the new URI of the token metadata


```solidity
function setBaseURI(string calldata _uri) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_uri`|`string`|Base URI pointer of the metadata|


### setPrice

Sets new price for given token


```solidity
function setPrice(uint256 _tokenId, uint80 _newPrice) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_newPrice`|`uint80`|New price of the token|


### taxes

Mapping of ticket ID to tax information (grace period, foreclosure time, current price, deposit amount)


```solidity
function taxes(uint256) external returns (uint48, uint48, uint80, uint80);
```

### totalSupply

Returns the current circulating supply of tokens


```solidity
function totalSupply() external returns (uint48);
```

### unpause

Unpauses all function executions where modifier is set


```solidity
function unpause() external;
```

### withdraw

Withdraws available balance amount to given address


```solidity
function withdraw(address _to) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address being withdrawn to|


## Events
### TicketInitialized
Event emitted when mint ticket is initialized


```solidity
event TicketInitialized(
    address indexed _genArt721,
    address indexed _redeemer,
    uint48 indexed _gracePeriod,
    string _baseURI,
    MintInfo[] _mintInfo
);
```

### Claimed
Event emitted when token is claimed at either listing or auction price


```solidity
event Claimed(
    uint256 indexed _tokenId,
    address indexed _claimer,
    uint128 _newPrice,
    uint48 _newForeclosureTime,
    uint80 _newDepositAmount,
    uint256 _payment
);
```

### Deposited
Event emitted when additional taxes are deposited


```solidity
event Deposited(uint256 indexed _tokenId, address indexed _depositer, uint48 _newForeclosure, uint80 _newTotalDeposit);
```

### SetPrice
Event emitted when new listing price is set


```solidity
event SetPrice(uint256 indexed _tokenId, uint128 _newPrice, uint128 _newForeclosure, uint128 _depositAmount);
```

### Withdraw
Event emitted when balance is withdrawn


```solidity
event Withdraw(address indexed _caller, address indexed _to, uint256 indexed _balance);
```

## Errors
### AllocationExceeded
Error thrown when total minter allocation exceeds maximum supply


```solidity
error AllocationExceeded();
```

### Foreclosure
Error thrown when token is in foreclosure


```solidity
error Foreclosure();
```

### GracePeriodActive
Error thrown when token is being claimed within the grace period


```solidity
error GracePeriodActive();
```

### InsufficientDeposit
Error thrown when deposit amount is not for at least one day


```solidity
error InsufficientDeposit();
```

### InsufficientPayment
Error thrown when payment amount does not meet price plus daily tax amount


```solidity
error InsufficientPayment();
```

### InvalidEndTime
Error thrown when reserve end time is invalid


```solidity
error InvalidEndTime();
```

### InvalidPrice
Error thrown when new listing price is less than the mininmum amount


```solidity
error InvalidPrice();
```

### InvalidStartTime
Error thrown when reserve start time is invalid


```solidity
error InvalidStartTime();
```

### MintActive
Error thrown when minting is active


```solidity
error MintActive();
```

### NotAuthorized
Error thrown when caller is not authorized to execute transaction


```solidity
error NotAuthorized();
```

### UnauthorizedAccount
Error thrown when caller does not have the specified role


```solidity
error UnauthorizedAccount();
```

### UnauthorizedMinter
Error thrown when caller does not have minter role


```solidity
error UnauthorizedMinter();
```

### UnauthorizedRedeemer
Error thrown when caller does not have the redeemer role


```solidity
error UnauthorizedRedeemer();
```

### UnregisteredMinter
Error thrown when caller is not a registered minter


```solidity
error UnregisteredMinter();
```
