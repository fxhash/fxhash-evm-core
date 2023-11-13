# ISeedConsumer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/interfaces/ISeedConsumer.sol)

**Author:**
fx(hash)

Interface for randomizers to interact with FxGenArt721 tokens


## Functions
### fulfillSeedRequest

Fullfills the random seed request on the FxGenArt721 token contract


```solidity
function fulfillSeedRequest(uint256 _tokenId, bytes32 _seed) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_seed`|`bytes32`|Hash of the random seed|


## Events
### SeedFulfilled
Event emitted when a seed request is fulfilled for a specific token


```solidity
event SeedFulfilled(address indexed _randomizer, uint256 indexed _tokenId, bytes32 _seed);
```

