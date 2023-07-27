# A quick list of todos available for everyone

- `contracts/gentk/GenTk.sol` > `assignOnChainMetadata`: if we are going to handle metadata onchain, we cannot upload the full metadata for every token. Name, description, tags, etc... can be constructed from the metadata of the issuer. Moreover, we're probably going to always go with offchain storage for the metadata for cost optimization reasons, so we may want to just remove this function eventually.
- `contracts/gentk/GenTk.sol` > `assignMetadata`: do we want to go with an array of tokens ? as discussed, calldata cost is exponential so it could be cheaper to reveal 1 by 1 ?
