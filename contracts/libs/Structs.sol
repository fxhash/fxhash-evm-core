// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IPricing} from "contracts/interfaces/IPricing.sol";
import {IReserve} from "contracts/interfaces/IReserve.sol";
import {WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";

///////////////////////////////////////////////////////////
//                         CODEX                         //
///////////////////////////////////////////////////////////
struct CodexData {
    uint256 entryType; // (uint88) => ipfs, arweave, onchain
    address author; // artist
    bool locked;
    address issuer;
    bytes[] value;
}

struct CodexInput {
    uint256 inputType;
    bytes value;
    uint256 codexId;
    address issuer;
}

///////////////////////////////////////////////////////////
//                     CONFIGURATION                     //
///////////////////////////////////////////////////////////
struct Config {
    uint256 fees; // 10000 bps (100%) (uint16)
    uint256 referrerFeesShare; // 10000 (uint16)
    uint256 lockTime; // less than 1 week
    string voidMetadata; // default metadata (same for all projects)
}

struct ContractEntry {
    string key; // name of contract (evolving)
    address value; // contract to call
}

///////////////////////////////////////////////////////////
//                       CYCLES                          //
///////////////////////////////////////////////////////////
struct CycleParams {
    uint128 start;
    uint64 openingDuration;
    uint64 closingDuration;
}

///////////////////////////////////////////////////////////
//                         GENTK                         //
///////////////////////////////////////////////////////////
struct TokenMetadata {
    uint256 tokenId;
    string metadata;
}

struct OnChainTokenMetadata {
    uint256 tokenId;
    bytes metadata;
}

struct TokenData {
    uint256 iteration; // is same as tokenId and not needed
    bytes inputBytes; // fxParams bytes params genrated (possibly use SSTORE2 and just store pointer)
    address minter; // might not being used
    bool assigned;
}

// scrap struct
struct TokenParams {
    uint256 tokenId;
    address receiver;
    uint256 iteration;
    bytes inputBytes;
    string metadata;
}

///////////////////////////////////////////////////////////
//                         ISSUER                        //
///////////////////////////////////////////////////////////
// not needed
struct OpenEditions {
    uint256 closingTime;
    bytes extra; // not being used
}

// Project supply, details and royalties
struct IssuerData {
    uint256 balance; // current available (can be removed)
    uint256 iterationsCount; // total minted
    bytes metadata; // IPFS pointer => could also be string
    uint256 supply; // max supply
    OpenEditions openEditions; // scrap and move closingTime here
    bytes reserves; // should be array of structs ({ reserve_id: int, reserve_data: bytes, amount: int } []) | FLO: I remember now why I encoded it as bytes, it is because we can't store nested struct arrays in the storage
    RoyaltyData primarySplit; // will come back to
    RoyaltyData royaltiesSplit; // will come back to
    IssuerInfo info;
    bytes onChainData; // scripty info (move to codex) | FLO: same here stored as bytes because we can't save nested struct arrays in the storage
}

// Baptiste left here

// Mint details
struct IssuerInfo {
    uint256[] tags; // integer identifers (max is 30000) => metadata-related (project attribute)
    bool enabled; // minting is active
    uint256 lockedSeconds; // duration for unverified artists (max is about 3 hrs)
    uint256 timestampMinted; // beginning of locked duration (can combine with lockedseconds to only store timestamp of when minting can be active)
    bool lockPriceForReserves; // Florian: when there is only one token remaining after deducting the reserves from the balance, and the lockPriceForReserves flag is enabled, the contract locks the current price - only for dutch auction
    bool hasTickets; // project has mint tickets | Florian: MintTicket could be replaced by a specific pricing contract to drastically reduce the cost. The data stored in the mint ticket are duplicated from the issuer, the only thing we actually need is the pricing logic
    uint256 pricingId; // uint8 (0 or 1) => evolving
    uint256 codexId;
    uint256 inputBytesSize; // specify size of input provided at mint time of token (fxParams size) => use different approach to enforce content
}

// Refactor Issue Structs into => ProjectInfo, TokenInfo, MintInfo, ReserveInfo

// FLO: This struct is only used as input for the updateIssuer entrypoints
// FLO: The entrypoint only allows for updating the primary/secondary split and the enable flag
struct UpdateIssuerInput {
    RoyaltyData primarySplit;
    RoyaltyData royaltiesSplit;
    bool enabled;
}

struct MintTicketSettings {
    /* FLO:
    The gracingPeriod determines the initial period after a ticket is minted during which the ticket is considered to be in a "gracing" state. During this period, certain actions may have different requirements or restrictions compared to the normal state of the ticket. The gracing period allows for special treatment or considerations for newly minted tickets before they fully enter the regular operational phase.
        * Minting Tickets: When a ticket is minted for a specific project, the gracingPeriod is used to calculate the ticket's expiration timestamp. The expiration timestamp is set as the current timestamp plus the gracingPeriod duration, ensuring that the ticket remains valid until the end of the gracing period.
        * Updating Price and Coverage: During the gracing period, there are specific requirements for updating the price and coverage of a ticket. The contract enforces that the coverage value must be greater than the remaining gracing days, indicating that coverage adjustments can only happen after the gracing period is complete. This restriction aims to provide stability and prevent frequent changes to coverage during the initial phase of a ticket.
        * Claiming a Ticket: The gracingPeriod is checked when a user claims a ticket. If a ticket is still within its gracing period, the claim action is restricted, and an error is thrown. This limitation ensures that tickets can only be claimed once the gracing period has elapsed, thereby preventing premature claims during the initial phase.
    */
    uint256 gracingPeriod; // in days
    string metadata; // FLO: This is just a an IPFS pointer for the metadata for Mint Ticket token. Same as mentionned earlier, this could be removed by replacing the mint ticket with a pricing strategy
}

// FLO: Can be removed and replaced by IssuerData as most of the actions done in the mintIsser function are checks, and not data modifications
struct MintIssuerInput {
    CodexInput codex; // FLO: This is the input that will be forwarded to the codex directly without any action done by the issuer
    bytes metadata; // FLO: same as in storage, either an IPFS pointer as bytes encoded string, or TokenAttribute[] encoded as bytes
    uint256 inputBytesSize; // FLO: like before, the expected size for the params payload
    uint256 amount; // is same as supply | FLO: it will be used at mint time to define the supply and balance
    OpenEditions openEditions; // FLO: same as before, can be removed to just add the gracing
    MintTicketSettings mintTicketSettings;
    ReserveData[] reserves;
    PricingData pricing;
    RoyaltyData primarySplit;
    RoyaltyData royaltiesSplit;
    bool enabled;
    uint256[] tags;
    WrappedScriptRequest[] onChainScripts; // FLO: these are the parameters for the Scripty request to fetch the on chain scripts. This should be encoded as bytes, and stored in the codex `CodexData.value` storage attribute. If this array is not empty, it should also affect `CodexData.entryType` to specify that it is on chain. WrappedScriptRequest[] is imported from Scripty directly
}

// FLO: simply the data used for minting a token for a specific project
struct MintInput {
    bytes inputBytes; // FLO: this is the fx param payload, must be 0 if the project is not using fxparams, or the exact inputBytesSize defined in the IssuerData
    address referrer; // FLO: can be empty, it is the address of the potential referrer that will get a part of the fees
    bytes reserveInput;
    /*
    |-> FLO: reserveInput
        can be empty, this is the payload that will be sent to the reserve manager if the project has any. It is actually and encoded LibReserve.ReserveInput
        struct ReserveInput {
            uint256 methodId;
            bytes input;
        }

        ReserveInput.input will be forwarded to the corresponding reserve contract and is LibReserve.ReserveData[] encoded as bytes
        struct ReserveData {
            uint256 methodId;
            uint256 amount;
            bytes data;
        }

        Example:
            --------------
            Whitelist case:
            --------------
                LibReserve.ReserveData[] memory reserves = new LibReserve.ReserveData[](1);
                ReserveWhitelist.WhitelistEntry[]
                    memory whitelistEntries = new ReserveWhitelist.WhitelistEntry[](1);

                whitelistEntries[0] = ReserveWhitelist.WhitelistEntry({
                    whitelisted: mintInput.recipient,
                    amount: 2
                });

                reserves[0] = LibReserve.ReserveData({
                    methodId: 1,
                    amount: 1,
                    data: abi.encode(whitelistEntries)
                });
                reserveInput = abi.encode(
                    LibReserve.ReserveInput({methodId: 1, input: abi.encode(reserves)})
                );

            ---------------------
            Mint Pass Group case:
            ---------------------
                LibReserve.ReserveData[] memory reserves = new LibReserve.ReserveData[](1);
                reserves[0] = LibReserve.ReserveData({
                    methodId: 2,
                    amount: 1,
                    data: abi.encode(mintInput.mintPassGroup)
                });
                reserveInput = abi.encode(
                    LibReserve.ReserveInput({
                        methodId: 2,
                        input: getMintPassGroupPayload(
                            mintInput.issuer,
                            mintInput.recipient,
                            mintInput.mintPassGroup
                        )
                    })
                );
    */
    bool createTicket; // FLO: specify if we need to use a ticket, but since this is defined on the IssuerData, I think it is useless and can be removed
    address recipient; // FLO: recipient of the minted token
}

// FLO: this struct is only used for the mintWithTicket function in the Issuer
struct MintWithTicketInput {
    uint256 ticketId; // FLO: this is the tokenId of the ticket to consume to mint the token
    bytes inputBytes; // FLO: can be empty, fxparams paylaod to be used for minting the token
    address recipient; // FLO: recipient of the minted token
}

///////////////////////////////////////////////////////////
//                      MARKETPLACE                      //
///////////////////////////////////////////////////////////

// FLO: simple enum to define all the token types used by the marketplace
enum TokenType {
    ETH,
    ERC20,
    ERC721,
    ERC1155
}

// FLO: struct defining the referrer that can be set in the marketplace functions it is used only as Referrer[] in the marketplace functions
struct Referrer {
    address referrer; // FLO: address of the referrer that will receive a part of the sale total
    uint256 share; // FLO: share of the referrer, must be < to the max value set in the contract storage, and will anyway be < 10000 (100% with 2 decimals)
}

// FLO: definition of an authorized currency
struct Currency {
    TokenType currencyType; // FLO: enum defining the token type
    bytes currencyData;
    /*
    currencyData
    // FLO: encoded value representing the token data.
        ETH: empty bytes
        ERC20: address encoded as bytes
        ERC721/ERC1155: (address, uint256) encoded as bytes
    */

    bool enabled; // FLO: flag defining if the currency can be used or not
}

// FLO: struct defining the traded token (ERC721)
struct Asset {
    address assetContract; // FLO: address of the token contract
    uint256 tokenId;
}

// FLO: struct defining a fixed price listing
struct Listing {
    Asset asset; // FLO: definition of the asset traded (ERC721)
    address seller; // FLO: address of the seller
    uint256 currency; // FLO: id of the currency used for the listing
    uint256 amount; // FLO: amount of fungible tokens of the currency used requested by the seller
}

// FLO: struct defining an offer on a list of assets
struct Offer {
    bytes assets; // FLO: again as we can't store nested struct arrays we store it as encoded bytes (it is Asset[]). It could be potentially be just a uint[] as we could only allow offers for tokens in the same project
    address buyer;
    uint256 currency; // FLO: id of the currency used for the offer
    uint256 amount; // FLO: amount of the currency proposed by the buyer
}

// FLO: struct used provided to the transfer method used by most of the marketplace funtions
struct TransferParams {
    address assetContract; // FLO: contract of the NFT
    uint256 tokenId; // FLO : token id of the nft
    address owner; // FLO : address of the owner of the nft
    address receiver; // FLO : address of the receiver of the NFT
    uint256 amount; // FLO: amount of currency to transfer
    TokenType tokenType; // FLO: type of the currency used
}

///////////////////////////////////////////////////////////
//                    MINT PASS GROUP                    //
///////////////////////////////////////////////////////////
// FLO: stores the values for a token
struct TokenRecord {
    uint256 minted; // FLO: number of token minted, should be quite small
    uint256 levelConsumed; // FLO: block level where the mint pass was consumed
    address consumer; // FLO: address of the user that consumed the pass
}

// FLO: the pass stores the payload for the consumePass function
// it is passed as bytes to the function, but now that I think about it, I don't think it is actually needed
struct Pass {
    bytes payload; // FLO: it is the Payload type encoded as bytes
    bytes signature; // FLO: this is the EIP712 signature of the hash of the Payload
}

// FLO: these are the real data used by the consume pass function
struct Payload {
    string token; // FLO: this is the identifier of the mint pass, not used on chain. Need @baptiste insights on this
    address project; // FLO: this is the address of the issuer, can be renamed to issuer
    address addr; // FLO: this is the address of the consumer of the pass (recipient of the token)
}

///////////////////////////////////////////////////////////
//                      MINT TICKET                      //
///////////////////////////////////////////////////////////

// FLO: struct representing what is stored for the mint ticket, most of it are duplicate from the issuer/token
struct TokenInfo {
    address issuer; // FLO: contract of the issuer contract that created the ticket
    address minter; // FLO: address of the consumer that minted the ticket
    uint256 createdAt; // FLO: creation timestamp
    uint256 taxationLocked; // FLO: used to track the amount of tax that has been paid and is currently locked for a specific token.
    uint256 taxationStart; // FLO: used to mark the starting point for calculating and tracking the taxation period of a token.
    uint256 price; // FLO: price of a mint ticket
}

struct ProjectData {
    uint256 gracingPeriod; //in days | FLO: see previous gacingPeriod explanation in MintTicketSettings
    string metadata; // FLO: same here, see MintTicketSettings
}

///////////////////////////////////////////////////////////
//                       MODERATION                      //
///////////////////////////////////////////////////////////
struct ModerationState {
    uint256 state;
    /* FLO:
Possible states for user and tokens:

const UserFlagValues: Record<UserFlag, number> = {
  NONE          : 0,
  REVIEW        : 1,
  SUSPICIOUS    : 2,
  MALICIOUS     : 3,
  VERIFIED      : 10,
}

export enum GenTokFlag {
  NONE = "NONE",                            // 0
  CLEAN = "CLEAN",                          // 1
  REPORTED = "REPORTED",                    // 2
  AUTO_DETECT_COPY = "AUTO_DETECT_COPY",    // 3
  MALICIOUS = "MALICIOUS",                  // 4
  HIDDEN = "HIDDEN",                        // 5
}
*/
    uint256 reason;
    /*
    Possible reasons values:

    user reasons:
[{
	"key": "0",
	"value": "Moderating from malicious to none because they repaired."
}, {
	"key": "1",
	"value": "Copyminter"
}, {
	"key": "2",
	"value": "Removing verification because they or and alternate account has engaged in malicious activity in the past"
}, {
	"key": "3",
	"value": "Taking advantage of scheduling exploit"
}, {
	"key": "4",
	"value": "Batch Moderation"
}, {
	"key": "5",
	"value": "Impersonification"
}, {
	"key": "6",
	"value": "Comes from a restricted chain"
}, {
	"key": "7",
	"value": "Market manipulation"
}, {
	"key": "8",
	"value": "Connected to a known malicious actor"
}, {
	"key": "9",
	"value": "Market manipulation"
}, {
	"key": "10",
	"value": "Mass Botting / Associated with coordinated botting group"
}, {
	"key": "11",
	"value": "Impersonation"
}]

Token reasons

[
  {
    "key": "0",
    "value": "Non-deterministic"
  },
  {
    "key": "1",
    "value": "Copymint"
  },
  {
    "key": "2",
    "value": "Non-generative: single image chosen at random"
  },
  {
    "key": "3",
    "value": "PNG composition, but primarily 1 layer"
  },
  {
    "key": "4",
    "value": "Artist requested hidden"
  },
  {
    "key": "5",
    "value": "Copyright Issue"
  },
  {
    "key": "6",
    "value": "Gambling"
  },
  {
    "key": "7",
    "value": "Malicious to hidden - user repaired"
  },
  {
    "key": "8",
    "value": "Double post (token also posted elsewhere)"
  },
  {
    "key": "9",
    "value": "Abuse of the rescheduling system"
  },
  {
    "key": "10",
    "value": "Misleading - Loading pre-generated imagery"
  },
  {
    "key": "11",
    "value": "Output not based on transaction hash"
  },
  {
    "key": "12",
    "value": "Loading external resources"
  },
  {
    "key": "13",
    "value": "Using copyrighted code without license and/or attribution"
  },
  {
    "key": "14",
    "value": "Unauthorized derivative / \"Inspired\" by without attribution"
  },
  {
    "key": "15",
    "value": "Broken"
  },
  {
    "key": "16",
    "value": "Misleading description "
  },
  {
    "key": "17",
    "value": "Connected to a known malicious actor"
  }
]
    */
}

// FLO: struct describing the data for a specific moderator
struct ModeratorData {
    uint256[] authorizations; // FLO: list of authorizations a moderator can have:
/*| Code | Authorization |
|------|---------------|
| `10` | Can moderate tokens, update the tags of a token |
| `20` | Can moderate users (ban, verification) |*/
    uint256 share; // FLO : share of the moderator to be able to pay him for his work
}

// FLO: input struct to be able to update a moderator authorizations, can be removed
struct UpdateModeratorParam {
    address moderator;
    uint256[] authorizations;
}

// FLO: input struct to be able to update a moderator share, can be removed
struct UpdateShareParam {
    address moderator;
    uint256 share;
}

///////////////////////////////////////////////////////////
//                ONCHAIN METADATA MANAGER               //
///////////////////////////////////////////////////////////

// FLO: list of token attributes to be able to reconstruct the JSON for the metadata. This will be encoded as bytes and stored in the tokenURI of the token
struct TokenAttribute {
    string key;
    string value;
}

///////////////////////////////////////////////////////////
//                       PRICING                         //
///////////////////////////////////////////////////////////

// FLO: struct defining the a pricing method with its address and if it is enabled or not. I guess it can be moved from the interface to an address ?
// I stored it as interface because I thought that casting it multiple times would be more expensive than storing it as interface
struct PricingContract {
    IPricing pricingContract;
    bool enabled;
}

// FLO: struct used in the issuer input to describe the pricing that will be used by the issuer contract (and the mint issuer function)
struct PricingData {
    uint256 pricingId; // FLO: Id of the pricing method stored
    bytes details; // FLO: payload used by the pricing method. The underlying data will be different based on the method
    /*
    example for prixing fixed:

                LibPricing.PricingData({
                pricingId: 1,
                details: abi.encode(
                    PricingFixed.PriceDetails({price: PRICE, opensAt: block.timestamp + OPEN_DELAY})
                ),
                lockForReserves: false
            });

    example for pricing dutch:

     uint256[] memory levels = new uint256[](4);
        levels[0] = PRICE;
        levels[1] = PRICE / 2;
        levels[2] = PRICE / 3;
        levels[3] = PRICE / 4;
        return
            LibPricing.PricingData({
                pricingId: 2,
                details: abi.encode(
                    PricingDutchAuction.PriceDetails({
                        opensAt: block.timestamp + OPEN_DELAY,
                        decrementDuration: 600,
                        lockedPrice: 0,
                        levels: levels
                    })
                ),
                lockForReserves: false
            });
    */
    bool lockForReserves; // FLO: see previous explanation for lockForReserves
}

// FLO: price details are actually different in Dutch and Fixed price
/*
See dutch version:

    struct PriceDetails {
        uint256 opensAt; // FLO : timestamp where the dutch auction start
        uint256 decrementDuration; // FLO: interval between each price decrement
        uint256 lockedPrice; // FLO: price to where it has been locked
        uint256[] levels; // FLO: price levels, in descending order
    }
*/
struct PriceDetails {
    uint256 price; // FLO: fixed price for minting
    uint256 opensAt; // FLO : timestamp where the token can be minted
}



///////////////////////////////////////////////////////////
//                         RANDOMIZER                    //
///////////////////////////////////////////////////////////

//FLO: struct used for identifying a token
struct TokenKey {
    address issuer; // FLO: address of the issuer
    uint256 tokenId; // FLO: token id of the token to reveal
}

//FLO: struct used to store the secret seed of the token
// As per our discussion we can merge `chainSeed` and `revealed` to save a slot, and move `serialId` to a `uint248`
// Optionally we can also replace `revealed` by a `bool`
struct Seed {
    bytes32 chainSeed; // FLO: when generated, this value is built this way:
    /*
        bytes32 hashedKey = keccak256(abi.encodePacked(issuer, id));
        bytes memory base = abi.encode(block.timestamp, hashedKey);
        bytes32 seed = keccak256(base);
    */
    // THis is probably too much processing for not that much added value
    uint256 serialId; // FLO: this is the value corresponding the value of the sequence used for generating ids
    bytes32 revealed; // FLO: in the current situation: empty if not revealed, and set to the secret hash when revealed (see randomizer impl)
}

// FLO: this struct stores the configuration for the randomizer, probably does not need to be in a struct
struct Commitment {
    bytes32 seed; // FLO: this value correspond to the last hash of the hash chain (the one from the token with the lowest index)
    bytes32 salt; // FLO: salt used to generate and iterate hashes
}

///////////////////////////////////////////////////////////
//                         RESERVE                       //
///////////////////////////////////////////////////////////

// FLO: this is the struct defining the payload for the IReserve.isInputValid function. Only used at mint issuer time
struct InputParams {
    bytes data; // FLO: the underlying data will be different depending on the reserve used
    /*
For whitelist:

        WhitelistEntry[] memory whitelist = abi.decode(params.data, (WhitelistEntry[]));

For MintPass:

        address unpackedData = abi.decode(params.data, (address)); --> address of the mint pass group contract

    */
    uint256 amount; // FLO: total amount of token for the reserve
    address sender; // FLO: creator of the issuer
}

// FLO: struct defining the input for the IReserve.applyReserve
struct ApplyParams {
    bytes currentData; // FLO: it is the reserve data currently stored in the issuer, will be different depending on the reserve used, see explanation above for InputParams.data (they are the same)
    uint256 currentAmount; // FLO: current amount of tokens in the reserve
    address sender; // FLO: address of the minter
    bytes userInput; // FLO : not used in the whitelist, but in the MintPassGroup it is Pass encoded as bytes
}

// FLO: struct defining the input used for the reserve with the id of the reserve, the amount of tokens, and the payload for the reserve
struct ReserveData {
    uint256 methodId;
    uint256 amount;
    bytes data; // FLO: it is the payload for the reserve contract encoded as bytes
}

struct ReserveInput {
    uint256 methodId;
    bytes input; // FLO: this is the ReserveData[] encoded as bytes, encoded as bytes. We can probably just use ReserveData[] here
}

// FLO: self explanatory, similar to pricing methods
struct ReserveMethod {
    IReserve reserveContract;
    bool enabled;
}


// FLO, pretty self explanatory, will be replaced by the merkle tree
struct WhitelistEntry {
    address whitelisted;
    uint256 amount;
}

///////////////////////////////////////////////////////////
//                       ROYALTY                         //
///////////////////////////////////////////////////////////
struct RoyaltyData {
    uint256 percent;
    address receiver;
}
