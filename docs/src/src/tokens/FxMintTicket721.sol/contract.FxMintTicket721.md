# FxMintTicket721
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/tokens/FxMintTicket721.sol)

**Inherits:**
[IFxMintTicket721](/src/interfaces/IFxMintTicket721.sol/interface.IFxMintTicket721.md), IERC4906, [IERC5192](/src/interfaces/IERC5192.sol/interface.IERC5192.md), ERC721, Initializable, Ownable, Pausable

**Author:**
fx(hash)

See the documentation in {IFxMintTicket721}


## State Variables
### contractRegistry
Returns the address of the FxContractRegistry contract


```solidity
address public immutable contractRegistry;
```


### roleRegistry
Returns the address of the FxRoleRegistry contract


```solidity
address public immutable roleRegistry;
```


### genArt721
Returns address of the FxGenArt721 token contract


```solidity
address public genArt721;
```


### totalSupply
Returns the current circulating supply of tokens


```solidity
uint48 public totalSupply;
```


### gracePeriod
Returns default grace period of time for each token


```solidity
uint48 public gracePeriod;
```


### baseURI
Returns the decoded content identifier of the metadata pointer


```solidity
bytes public baseURI;
```


### redeemer
Returns the address of the TickeRedeemer contract


```solidity
address public redeemer;
```


### renderer
Returns the address of the renderer contract


```solidity
address public renderer;
```


### activeMinters
Returns the list of active minters


```solidity
address[] public activeMinters;
```


### balances
Mapping of wallet address to pending balance available for withdrawal


```solidity
mapping(address => uint256) public balances;
```


### minters
Returns the active status of a registered minter contract


```solidity
mapping(address => uint8) public minters;
```


### taxes
Mapping of ticket ID to tax information (grace period, foreclosure time, current price, deposit amount)


```solidity
mapping(uint256 => TaxInfo) public taxes;
```


## Functions
### onlyRole

*Modifier for restricting calls to only callers with the specified role*


```solidity
modifier onlyRole(bytes32 _role);
```

### constructor

*Initializes FxContractRegistry and FxRoleRegistry*


```solidity
constructor(address _contractRegistry, address _roleRegistry) ERC721("FxMintTicket721", "FXTICKET");
```

### initialize

Initializes new generative art project


```solidity
function initialize(
    address _owner,
    address _genArt721,
    address _redeemer,
    address _renderer,
    uint48 _gracePeriod,
    MintInfo[] calldata _mintInfo
) external initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|Address of contract owner|
|`_genArt721`|`address`|Address of GenArt721 token contract|
|`_redeemer`|`address`|Address of TicketRedeemer minter contract|
|`_renderer`|`address`|Address of renderer contract|
|`_gracePeriod`|`uint48`|Period time before token enters harberger taxation|
|`_mintInfo`|`MintInfo[]`|Array of authorized minter contracts and their reserves|


### burn

Burns token ID from the circulating supply


```solidity
function burn(uint256 _tokenId) external whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|


### claim

Claims token at current price and sets new price of token with initial deposit amount


```solidity
function claim(uint256 _tokenId, uint256 _maxPrice, uint80 _newPrice) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_maxPrice`|`uint256`|Maximum payment amount allowed to prevent front-running of listing price|
|`_newPrice`|`uint80`|New listing price of token|


### depositAndSetPrice

Deposits taxes for given token and set new price for same token


```solidity
function depositAndSetPrice(uint256 _tokenId, uint80 _newPrice) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_newPrice`|`uint80`|New listing price of token|


### mint


```solidity
function mint(address _to, uint256 _amount, uint256 _payment) external whenNotPaused;
```

### updateStartTime

Updates taxation start time to the current timestamp


```solidity
function updateStartTime(uint256 _tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|


### withdraw

Withdraws available balance amount to given address


```solidity
function withdraw(address _to) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address being withdrawn to|


### deposit

Deposits taxes for given token


```solidity
function deposit(uint256 _tokenId) public payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|


### setPrice

Sets new price for given token


```solidity
function setPrice(uint256 _tokenId, uint80 _newPrice) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_newPrice`|`uint80`|New price of the token|


### registerMinters

Registers minter contracts with resereve info


```solidity
function registerMinters(MintInfo[] calldata _mintInfo) external onlyOwner;
```

### setBaseURI

Sets the new URI of the token metadata


```solidity
function setBaseURI(bytes calldata _uri) external onlyRole(METADATA_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_uri`|`bytes`|Decoded content identifier of metadata pointer|


### pause

Pauses all function executions where modifier is set


```solidity
function pause() external onlyRole(MODERATOR_ROLE);
```

### unpause

Unpauses all function executions where modifier is set


```solidity
function unpause() external onlyRole(MODERATOR_ROLE);
```

### contractURI

Gets the contact-level metadata for the ticket


```solidity
function contractURI() external view returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|URI of the contract metadata|


### locked

Returns the locking status of an Soulbound Token

*SBTs assigned to zero address are considered invalid, and queries about them do throw*


```solidity
function locked(uint256 _tokenId) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`||


### primaryReceiver


```solidity
function primaryReceiver() external view returns (address);
```

### isApprovedForAll


```solidity
function isApprovedForAll(address _owner, address _operator) public view override(ERC721, IERC721) returns (bool);
```

### tokenURI


```solidity
function tokenURI(uint256 _tokenId) public view override returns (string memory);
```

### getAuctionPrice

Gets the current auction price of the token


```solidity
function getAuctionPrice(uint256 _currentPrice, uint256 _foreclosureTime) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_currentPrice`|`uint256`|Listing price of the token|
|`_foreclosureTime`|`uint256`|Timestamp of the foreclosure|


### getDepositAmounts

Gets the deposit amount owed and remaining after change in price, claim or burn


```solidity
function getDepositAmounts(uint256 _dailyTax, uint256 _depositAmount, uint256 _foreclosureTime)
    public
    view
    returns (uint256 depositOwed, uint256 depositRemaining);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dailyTax`|`uint256`|Daily tax amount based on current price|
|`_depositAmount`|`uint256`|Total amount of taxes deposited|
|`_foreclosureTime`|`uint256`|Timestamp of current foreclosure|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`depositOwed`|`uint256`|Deposit amount owed|
|`depositRemaining`|`uint256`||


### isForeclosed

Checks if token is foreclosed


```solidity
function isForeclosed(uint256 _tokenId) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Status of foreclosure|


### getDailyTax

Gets the daily tax amount based on current price


```solidity
function getDailyTax(uint256 _currentPrice) public pure returns (uint256);
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
function getExcessTax(uint256 _dailyTax, uint256 _depositAmount) public pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dailyTax`|`uint256`|Daily tax amount based on current price|
|`_depositAmount`|`uint256`|Total amount of taxes deposited|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Excess amount of taxes|


### getNewForeclosure

Gets the new foreclosure timestamp


```solidity
function getNewForeclosure(uint256 _dailyTax, uint256 _depositAmount, uint256 _currentForeclosure)
    public
    pure
    returns (uint48);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dailyTax`|`uint256`|Daily tax amount based on current price|
|`_depositAmount`|`uint256`|Amount of taxes being deposited|
|`_currentForeclosure`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint48`|Timestamp of new foreclosure|


### getTaxDuration

Gets the total duration of time covered


```solidity
function getTaxDuration(uint256 _dailyTax, uint256 _depositAmount) public pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dailyTax`|`uint256`|Daily tax amount based on current price|
|`_depositAmount`|`uint256`|Amount of taxes being deposited|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Total time duration|


### _registerMinters

*Registers arbitrary number of minter contracts and sets their reserves*


```solidity
function _registerMinters(MintInfo[] memory _mintInfo) internal;
```

### _beforeTokenTransfer

*Tokens can only be transferred when either of these conditions is met:
1) This contract executes transfer when token is in foreclosure and claimed at auction price
2) This contract executes transfer when token is not in foreclosure and claimed at listing price
3) Token owner executes transfer when token is not in foreclosure
4) Registered minter contract executes burn when token is not in foreclosure*


```solidity
function _beforeTokenTransfer(address _from, address, uint256 _tokenId, uint256) internal view override;
```

### _isVerified

*Checks if creator is verified by the system*


```solidity
function _isVerified(address _creator) internal view returns (bool);
```

