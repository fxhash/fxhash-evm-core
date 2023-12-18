# FixedPrice
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/minters/FixedPrice.sol)

**Inherits:**
[IFixedPrice](/src/interfaces/IFixedPrice.sol/interface.IFixedPrice.md), [Allowlist](/src/minters/extensions/Allowlist.sol/abstract.Allowlist.md), [MintPass](/src/minters/extensions/MintPass.sol/abstract.MintPass.md), Ownable, Pausable

**Author:**
fx(hash)

*See the documentation in {IFixedPrice}*


## State Variables
### claimedMerkleTreeSlots
*Mapping of token address to reserve ID to Bitmap of claimed merkle tree slots*


```solidity
mapping(address => mapping(uint256 => LibBitmap.Bitmap)) internal claimedMerkleTreeSlots;
```


### claimedMintPasses
*Mapping of token address to reserve ID to Bitmap of claimed mint passes*


```solidity
mapping(address => mapping(uint256 => LibBitmap.Bitmap)) internal claimedMintPasses;
```


### latestUpdates
*Mapping of token address to timestamp of latest update made for token reserves*


```solidity
LibMap.Uint40Map internal latestUpdates;
```


### firstValidReserve
*Mapping of token to the last valid reserveId that can mint on behalf of the token*


```solidity
LibMap.Uint40Map internal firstValidReserve;
```


### saleProceeds
*Mapping of token address to sale proceeds*


```solidity
LibMap.Uint128Map internal saleProceeds;
```


### merkleRoots
Mapping of token address to reserve ID to merkle roots


```solidity
mapping(address => mapping(uint256 => bytes32)) public merkleRoots;
```


### prices
Mapping of token address to reserve ID to prices


```solidity
mapping(address => uint256[]) public prices;
```


### reserves
Mapping of token address to reserve ID to reserve information


```solidity
mapping(address => ReserveInfo[]) public reserves;
```


## Functions
### buy

Purchases tokens at a fixed price


```solidity
function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable whenNotPaused;
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
) external payable whenNotPaused;
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
) external payable whenNotPaused;
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


### setMintDetails

*Mint Details: token price, merkle root, and signer address*


```solidity
function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintDetails) external whenNotPaused;
```

### withdraw

Withdraws the sale proceeds to the sale receiver


```solidity
function withdraw(address _token) external whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token withdrawing proceeds from|


### pause

Pauses all function executions where modifier is applied


```solidity
function pause() external onlyOwner;
```

### unpause

Unpauses all function executions where modifier is applied


```solidity
function unpause() external onlyOwner;
```

### getFirstValidReserve

Returns the earliest valid reserveId that can mint a token


```solidity
function getFirstValidReserve(address _token) public view returns (uint256);
```

### getLatestUpdate

Gets the latest timestamp update made to token reserves


```solidity
function getLatestUpdate(address _token) public view returns (uint40);
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
function getSaleProceed(address _token) public view returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint128`|Amount of proceeds|


### _buy

*Purchases arbitrary amount of tokens at auction price and mints tokens to given account*


```solidity
function _buy(address _token, uint256 _reserveId, uint256 _amount, address _to) internal;
```

### _setLatestUpdate

*Sets timestamp of the latest update to token reserves*


```solidity
function _setLatestUpdate(address _token, uint256 _timestamp) internal;
```

### _setFirstValidReserve

*Sets earliest valid reserve*


```solidity
function _setFirstValidReserve(address _token, uint256 _reserveId) internal;
```

### _setSaleProceeds

*Sets the proceed amount from the token sale*


```solidity
function _setSaleProceeds(address _token, uint256 _amount) internal;
```

### _getMerkleRoot

*Gets the merkle root of a token reserve*


```solidity
function _getMerkleRoot(address _token, uint256 _reserveId) internal view override returns (bytes32);
```

