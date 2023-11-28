# IFixedPrice
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/interfaces/IFixedPrice.sol)

**Inherits:**
[IMinter](/src/interfaces/IMinter.sol/interface.IMinter.md)

**Author:**
fx(hash)

Minter for distributing tokens at fixed prices


## Functions
### buy

Purchases tokens at a fixed price


```solidity
function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token contract|
|`_reserveId`|`uint256`|ID of the reserve|
|`_amount`|`uint256`|Amount of tokens being purchased|
|`_to`|`address`|Address receiving the purchased tokens|


### buyAllowlist

Purchases tokens through an allowlist at a fixed price


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
|`_indexes`|`uint256[]`|Array of indices regarding purchase info inside the BitMap|
|`_proofs`|`bytes32[][]`|Array of merkle proofs used for verifying the purchase|


### buyMintPass

Purchases tokens through a mint pass at a fixed price


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


### getSaleProceed

Gets the proceed amount from a token sale


```solidity
function getSaleProceed(address _token) external view returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint128`|Amount of proceeds|


### merkleRoots

Mapping of token address to reserve ID to merkle roots


```solidity
function merkleRoots(address, uint256) external view returns (bytes32);
```

### prices

Mapping of token address to reserve ID to prices


```solidity
function prices(address, uint256) external view returns (uint256);
```

### reserves

Mapping of token address to reserve ID to reserve information


```solidity
function reserves(address, uint256) external view returns (uint64, uint64, uint128);
```

### setMintDetails

Sets the mint details for token reserves

*Mint Details: token price, merkle root, and signer address*


```solidity
function setMintDetails(ReserveInfo calldata _reserveInfo, bytes calldata _mintDetails) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserveInfo`|`ReserveInfo`|Reserve information for the token|
|`_mintDetails`|`bytes`|Details of the mint pertaining to the minter|


### withdraw

Withdraws the sale proceeds to the sale receiver


```solidity
function withdraw(address _token) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token withdrawing proceeds from|


## Events
### MintDetailsSet
Event emitted when a new fixed price mint has been set


```solidity
event MintDetailsSet(
    address indexed _token,
    uint256 indexed _reserveId,
    uint256 _price,
    ReserveInfo _reserveInfo,
    bytes32 _merkleRoot,
    address _mintPassSigner,
    bool _openEdition,
    bool _timeUnlimited
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token being minted|
|`_reserveId`|`uint256`|ID of the reserve|
|`_price`|`uint256`|Amount of fixed price mint|
|`_reserveInfo`|`ReserveInfo`|Reserve information for the mint|
|`_merkleRoot`|`bytes32`|The merkle root allowlisted buyers|
|`_mintPassSigner`|`address`|The signing account for mint passes|
|`_openEdition`|`bool`|Status of an open edition mint|
|`_timeUnlimited`|`bool`|Status of a mint with unlimited time|

### Purchase
Event emitted when a purchase is made


```solidity
event Purchase(
    address indexed _token,
    uint256 indexed _reserveId,
    address indexed _buyer,
    uint256 _amount,
    address _to,
    uint256 _price
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token being purchased|
|`_reserveId`|`uint256`|ID of the mint|
|`_buyer`|`address`|Address purchasing the tokens|
|`_amount`|`uint256`|Amount of tokens being purchased|
|`_to`|`address`|Address to which the tokens are being transferred|
|`_price`|`uint256`|Price of the purchase|

### Withdrawn
Event emitted when sale proceeds are withdrawn


```solidity
event Withdrawn(address indexed _token, address indexed _creator, uint256 _proceeds);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token|
|`_creator`|`address`|Address of the project creator|
|`_proceeds`|`uint256`|Amount of proceeds being withdrawn|

## Errors
### AddressZero
Error thrown when receiver is zero address


```solidity
error AddressZero();
```

### Ended
Error thrown when the sale has already ended


```solidity
error Ended();
```

### InsufficientFunds
Error thrown when no funds available to withdraw


```solidity
error InsufficientFunds();
```

### InvalidAllocation
Error thrown when the allocation amount is zero


```solidity
error InvalidAllocation();
```

### InvalidPayment
Error thrown when payment does not equal price


```solidity
error InvalidPayment();
```

### InvalidReserve
Error thrown thrown when reserve does not exist


```solidity
error InvalidReserve();
```

### InvalidTimes
Error thrown when reserve start and end times are invalid


```solidity
error InvalidTimes();
```

### InvalidToken
Error thrown when token address is invalid


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

### NoSigningAuthority
Error thrown when buy with a mint pass and no signing authority exists


```solidity
error NoSigningAuthority();
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

### TooMany
Error thrown when amount purchased exceeds remaining allocation


```solidity
error TooMany();
```

