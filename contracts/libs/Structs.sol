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
    bytes reserves; // should be array of structs ({ reserve_id: int, reserve_data: bytes, amount: int } [])
    RoyaltyData primarySplit; // will come back to
    RoyaltyData royaltiesSplit; // will come back to
    IssuerInfo info;
    bytes onChainData; // scripty info (move to codex)
}

// Baptiste left here

// Mint details
struct IssuerInfo {
    uint256[] tags; // integer identifers (max is 30000) => metadata-related (project attribute)
    bool enabled; // minting is active
    uint256 lockedSeconds; // duration for unverified artists (max is about 3 hrs)
    uint256 timestampMinted; // beginning of locked duration (can combine with lockedseconds to only store timestamp of when minting can be active)
    bool lockPriceForReserves; // edge case
    bool hasTickets; // project has mint tickets
    uint256 pricingId; // uint8 (0 or 1) => evolving
    uint256 codexId;
    uint256 inputBytesSize; // specify size of input provided at mint time of token (fxParams size) => use different approach to enforce content
}

// Refactor Issue Structs into => ProjectInfo, TokenInfo, MintInfo, ReserveInfo

struct UpdateIssuerInput {
    RoyaltyData primarySplit;
    RoyaltyData royaltiesSplit;
    bool enabled;
}

struct MintTicketSettings {
    uint256 gracingPeriod; //in days
    string metadata;
}

struct MintIssuerInput {
    CodexInput codex;
    bytes metadata;
    uint256 inputBytesSize;
    uint256 amount; // is same as supply
    OpenEditions openEditions;
    MintTicketSettings mintTicketSettings;
    ReserveData[] reserves;
    PricingData pricing;
    RoyaltyData primarySplit;
    RoyaltyData royaltiesSplit;
    bool enabled;
    uint256[] tags;
    WrappedScriptRequest[] onChainScripts;
}

struct MintInput {
    bytes inputBytes;
    address referrer;
    bytes reserveInput;
    bool createTicket;
    address recipient;
}

struct MintWithTicketInput {
    uint256 ticketId;
    bytes inputBytes;
    address recipient;
}

///////////////////////////////////////////////////////////
//                      MARKETPLACE                      //
///////////////////////////////////////////////////////////
enum TokenType {
    ETH,
    ERC20,
    ERC721,
    ERC1155
}

struct Referrer {
    address referrer;
    uint256 share;
}

struct Currency {
    TokenType currencyType;
    bytes currencyData;
    bool enabled;
}

struct Asset {
    address assetContract;
    uint256 tokenId;
}

struct Listing {
    Asset asset;
    address seller;
    uint256 currency;
    uint256 amount;
}

struct Offer {
    bytes assets;
    address buyer;
    uint256 currency;
    uint256 amount;
}

struct TransferParams {
    address assetContract;
    uint256 tokenId;
    address owner;
    address receiver;
    uint256 amount;
    TokenType tokenType;
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
