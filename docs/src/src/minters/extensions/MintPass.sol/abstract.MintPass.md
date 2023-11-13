# MintPass
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/3196ec292bff15f41085b94e4b488f73ce88013c/src/minters/extensions/MintPass.sol)

**Inherits:**
EIP712

**Author:**
fx(hash)

Extension for claiming tokens through mint passes


## State Variables
### signingAuthorities
Mapping of token address to reserve ID to address of mint pass authority


```solidity
mapping(address => mapping(uint256 => address)) public signingAuthorities;
```


### reserveNonce
Mapping of token address to reserve ID to reserve nonce


```solidity
mapping(address => mapping(uint256 => uint256)) public reserveNonce;
```


## Functions
### constructor

*Initializes EIP-712*


```solidity
constructor() EIP712("MINT_PASS", "1");
```

### generateTypedDataHash

Generates the typed data hash for a mint pass claim


```solidity
function generateTypedDataHash(
    address _token,
    uint256 _reserveId,
    uint256 _reserveNonce,
    uint256 _index,
    address _claimer
) public view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|address of token for the reserve|
|`_reserveId`|`uint256`|Id of the reserve to mint the token from|
|`_reserveNonce`|`uint256`||
|`_index`|`uint256`|Index of the mint pass|
|`_claimer`|`address`|Address of mint pass claimer|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|Digest of typed data hash claimer|


### _claimMintPass

*Validates a mint pass claim*


```solidity
function _claimMintPass(
    address _token,
    uint256 _reserveId,
    uint256 _index,
    bytes calldata _signature,
    LibBitmap.Bitmap storage _bitmap
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of the token contract|
|`_reserveId`|`uint256`|ID of the reserve|
|`_index`|`uint256`|Index of the mint pass|
|`_signature`|`bytes`|Signature of the mint pass claimer|
|`_bitmap`|`LibBitmap.Bitmap`|Bitmap used for checking if index is already claimed|


## Events
### PassClaimed
Event emitted when mint pass is claimed


```solidity
event PassClaimed(address indexed _token, uint256 indexed _reserveId, address indexed _claimer, uint256 _index);
```

## Errors
### InvalidSignature
Error thrown when the signature of mint pass claimer is invalid


```solidity
error InvalidSignature();
```

### PassAlreadyClaimed
Error thrown when a mint pass has already been claimed


```solidity
error PassAlreadyClaimed();
```

