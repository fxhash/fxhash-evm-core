# Allowlist
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/22e6538fd4576a4eee62705cd3e376e2623a19b3/src/minters/extensions/Allowlist.sol)

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

