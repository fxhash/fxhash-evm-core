# A quick list of todos available for everyone

- [GenTk](contracts/gentk/GenTk.sol) > `assignOnChainMetadata`: if we are going to handle metadata onchain, we cannot upload the full metadata for every token. Name, description, tags, etc... can be constructed from the metadata of the issuer. Moreover, we're probably going to always go with offchain storage for the metadata for cost optimization reasons, so we may want to just remove this function eventually.
- [GenTk](contracts/gentk/GenTk.sol) > `assignMetadata`: do we want to go with an array of tokens ? as discussed, calldata cost is exponential so it could be cheaper to reveal 1 by 1 ?
- [IAllowMintIssuer](contracts/interfaces/IAllowMintIssuer.sol) > mint delay: we can probably just remove the mint delay on ETH. Effectively, the costs to create a new projects are acting as a safe-guard which prevents spam by nature. Plus, because we can easily moderate spam, it's removing incentive to try spamming.
- [ICodex](contracts/interfaces/ICodex.sol) > `insertOrUpdateCodex`: we probably don't need to update a codex entry on ETH because we are using scripty to upload script data. as such we'll only create a codex entry referencing the scripty insertions.
- [ICodex](contracts/interfaces/ICodex.sol) > `codexLockEntry`: same as above
- [ICodex](contracts/interfaces/ICodex.sol) > `codexUpdateEntry`: same as above
- [ICodex](contracts/interfaces/ICodex.sol) > `updateIssuerCodexRequest`: this should be moved to the issuer, we are updating the codex pointer of an issuer, not directly a codex entry. codex entries are immutable once locked.
- [IIssuer](contracts/interfaces/IIssuer.sol) > `mintIssuer`: needs to be removed in favor of Factory instanciation
- [IIssuer](contracts/interfaces/IIssuer.sol) > `setCodex`: see `updateIssuerCodexRequest` above (we need to change the mechanism of updating the codex to match the request/approve pattern)
- [IMintTicket](contracts/interfaces/IMintTicket.sol) > `createProject`: instead of having 1 contract for all the projects, use the same Factory pattern to have 1 contract for the tickets as well
- [IMintTicket](contracts/interfaces/IMintTicket.sol) > `consume`: (see point above) once we migrate to the factory pattern for the mint ticket contract, the issuer will not be required in the field (as inferred by having 1 ticket contract per issuer)
- `Randomizer`: better implementation of how numbers are randomized
- [IReserve](contracts/interfaces/IReserve.sol): Need to update the implementation, as this current one only supports 1 source of data for tracking a reserve (which is going to change with the merkle implementation for access lists)
- [Codex](contracts/issuer/Codex.sol) > `codexInsert`: (_not sure if it's already been discussed during refacto of structs_) the codex should be agnostic of the issuer, it's simply a registry of code entries which can be used by the issuers. Basically we could just have a codex entry / issuer. **Maybe simply better ?**

# Questions

- [IMintTicket](contracts/interfaces/IMintTicket.sol#L53) > `mint`: is `minter` the right way to describe the recipient of the mint ? non-idomatic imo
- [IPricingManager](contracts/interfaces/IPricingManager.sol): do we have a single pricing contract for all the issuers ? or do we create a new contract for every new issuer ?
