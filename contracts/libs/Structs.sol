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
struct TokenRecord {
    uint256 minted;
    uint256 levelConsumed;
    address consumer;
}

struct Pass {
    bytes payload;
    bytes signature;
}

struct Payload {
    string token;
    address project;
    address addr;
}

///////////////////////////////////////////////////////////
//                      MINT TICKET                      //
///////////////////////////////////////////////////////////
struct TokenInfo {
    address issuer;
    address minter;
    uint256 createdAt;
    uint256 taxationLocked;
    uint256 taxationStart;
    uint256 price;
}

struct ProjectData {
    uint256 gracingPeriod; //in days
    string metadata;
}

///////////////////////////////////////////////////////////
//                       MODERATION                      //
///////////////////////////////////////////////////////////
struct ModerationState {
    uint256 state;
    uint256 reason;
}

struct ModeratorData {
    uint256[] authorizations;
    uint256 share;
}

struct UpdateModeratorParam {
    address moderator;
    uint256[] authorizations;
}

struct UpdateShareParam {
    address moderator;
    uint256 share;
}

///////////////////////////////////////////////////////////
//                ONCHAIN METADATA MANAGER               //
///////////////////////////////////////////////////////////
struct TokenAttribute {
    string key;
    string value;
}

///////////////////////////////////////////////////////////
//                       PRICING                         //
///////////////////////////////////////////////////////////
struct PricingContract {
    IPricing pricingContract;
    bool enabled;
}

struct PricingData {
    uint256 pricingId;
    bytes details;
    bool lockForReserves;
}

struct PriceDetails {
    uint256 price;
    uint256 opensAt;
}

///////////////////////////////////////////////////////////
//                         RANDOMIZER                    //
///////////////////////////////////////////////////////////
struct TokenKey {
    address issuer;
    uint256 tokenId;
}

struct Seed {
    bytes32 chainSeed;
    uint256 serialId;
    bytes32 revealed;
}

struct Commitment {
    bytes32 seed;
    bytes32 salt;
}

///////////////////////////////////////////////////////////
//                         RESERVE                       //
///////////////////////////////////////////////////////////
struct InputParams {
    bytes data;
    uint256 amount;
    address sender;
}

struct ApplyParams {
    bytes currentData;
    uint256 currentAmount;
    address sender;
    bytes userInput;
}

struct ReserveData {
    uint256 methodId;
    uint256 amount;
    bytes data;
}

struct ReserveInput {
    uint256 methodId;
    bytes input;
}

struct ReserveMethod {
    IReserve reserveContract;
    bool enabled;
}

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
