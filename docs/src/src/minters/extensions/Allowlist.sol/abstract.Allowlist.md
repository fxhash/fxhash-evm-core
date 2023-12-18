# Allowlist
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/minters/extensions/Allowlist.sol)

**Author:**
fx(hash)

Extension for claiming tokens through merkle trees


## Functions
### _claimSlot

*Claims a merkle tree slot*


```solidity
function _claimSlot(
    address _token,
    uint256 _reserveId,
    uint256 _index,
    address _claimer,
    bytes32[] memory _proof,
    LibBitmap.Bitmap storage _bitmap
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token contract|
|`_reserveId`|`uint256`|ID of the reserve|
|`_index`|`uint256`|Index in the merkle tree|
|`_claimer`|`address`|Address of allowlist slot claimer|
|`_proof`|`bytes32[]`|Merkle proof used for validating claim|
|`_bitmap`|`LibBitmap.Bitmap`|Bitmap used for checking if index is already claimed|


### _getMerkleRoot

*Gets the merkle root of a token reserve*


```solidity
function _getMerkleRoot(address _token, uint256 _reserveId) internal view virtual returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token contract|
|`_reserveId`|`uint256`|ID of the reserve|


## Events
### SlotClaimed
Event emitted when allowlist slot is claimed


```solidity
event SlotClaimed(address indexed _token, uint256 indexed _reserveId, address indexed _claimer, uint256 _index);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token|
|`_reserveId`|`uint256`|ID of the reserve|
|`_claimer`|`address`|Address of the claimer|
|`_index`|`uint256`|Index of purchase info inside the BitMap|

## Errors
### InvalidProof
Error thrown when the merkle proof for an index is invalid


```solidity
error InvalidProof();
```

### SlotAlreadyClaimed
Error thrown when an index in the merkle tree has already been claimed


```solidity
error SlotAlreadyClaimed();
```

