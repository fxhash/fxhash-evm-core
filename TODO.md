# A quick list of todos available for everyone

- `contracts/gentk/GenTk.sol` > `assignOnChainMetadata`: if we are going to handle metadata onchain, we cannot upload the full metadata for every token. Name, description, tags, etc... can be constructed from the metadata of the issuer. Moreover, we're probably going to always go with offchain storage for the metadata for cost optimization reasons, so we may want to just remove this function eventually.
- `contracts/gentk/GenTk.sol` > `assignMetadata`: do we want to go with an array of tokens ? as discussed, calldata cost is exponential so it could be cheaper to reveal 1 by 1 ?
- `contracts/interfaces/IAllowMintIssuer.sol` > mint delay: we can probably just remove the mint delay on ETH. Effectively, the costs to create a new projects are acting as a safe-guard which prevents spam by nature. Plus, because we can easily moderate spam, it's removing incentive to try spamming.
- `contracts/interfaces/ICodex.sol` > `insertOrUpdateCodex`: we probably don't need to update a codex entry on ETH because we are using scripty to upload script data. as such we'll only create a codex entry referencing the scripty insertions.
- `contracts/interfaces/ICodex.sol` > `codexLockEntry`: same as above
- `contracts/interfaces/ICodex.sol` > `codexUpdateEntry`: same as above
- `contracts/interfaces/ICodex.sol` > `updateIssuerCodexRequest`: this should be moved to the issuer, we are updating the codex pointer of an issuer, not directly a codex entry. codex entries are immutable once locked.
