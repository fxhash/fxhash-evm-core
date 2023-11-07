# DutchAuction
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/22e6538fd4576a4eee62705cd3e376e2623a19b3/src/minters/DutchAuction.sol)

**Inherits:**
[IDutchAuction](/src/interfaces/IDutchAuction.sol/interface.IDutchAuction.md), [Allowlist](/src/minters/extensions/Allowlist.sol/abstract.Allowlist.md), [MintPass](/src/minters/extensions/MintPass.sol/abstract.MintPass.md)

**Author:**
fx(hash)

*See the documentation in {IDutchAuction}*


## State Variables
### _claimedMerkleTreeSlots
*Mapping of token address to reserve ID to Bitmap of claimed merkle tree slots*


```solidity
mapping(address => mapping(uint256 => LibBitmap.Bitmap)) internal _claimedMerkleTreeSlots;
```


### _claimedMintPasses
*Mapping of token address to reserve ID to Bitmap of claimed mint passes*


```solidity
mapping(address => mapping(uint256 => LibBitmap.Bitmap)) internal _claimedMintPasses;
```


### _latestUpdates
*Mapping of token address to timestamp of latest update made for token reserves*


```solidity
LibMap.Uint40Map internal _latestUpdates;
```


### auctions
Mapping of token address to reserve ID to reserve information


```solidity
mapping(address => AuctionInfo[]) public auctions;
```


### merkleRoots
Mapping of token address to reserve ID to merkle root


```solidity
mapping(address => mapping(uint256 => bytes32)) public merkleRoots;
```


### refunds
Mapping of token address to reserve ID to refund amount


```solidity
mapping(address => mapping(uint256 => RefundInfo)) public refunds;
```


### reserves
Mapping of token address to reserve ID to reserve information (allocation, price, max mint)


```solidity
mapping(address => ReserveInfo[]) public reserves;
```


### saleProceeds
Mapping of token address to reserve ID to amount of sale proceeds


```solidity
mapping(address => mapping(uint256 => uint256)) public saleProceeds;
```


### numberMinted
Mapping of token address to reserve ID to number of tokens minted


```solidity
mapping(address => mapping(uint256 => uint256)) public numberMinted;
```


## Functions
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


### setMintDetails

*Mint Details: struct of auction information, merkle root, and signer address*


```solidity
function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintDetails) external;
```

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


### getPrice

Gets the current auction price


```solidity
function getPrice(address _token, uint256 _reserveId) public view returns (uint256);
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

### _getMerkleRoot

*Gets the merkle root of a token reserve*


```solidity
function _getMerkleRoot(address _token, uint256 _reserveId) internal view override returns (bytes32);
```

### _getPrice

*Gets the current price of auction reserve*


```solidity
function _getPrice(ReserveInfo memory _reserve, AuctionInfo storage _daInfo) internal view returns (uint256);
```

### _recordLastPrice


```solidity
function _recordLastPrice(ReserveInfo memory _reserve, address _token, uint256 _reserveId) internal returns (uint256);
```

### _validateInput

*Validates token address, reserve information and given account*


```solidity
function _validateInput(address _token, uint256 _reserveId, address _buyer) internal view;
```

