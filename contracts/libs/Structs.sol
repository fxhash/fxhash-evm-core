// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IPricing} from "contracts/interfaces/IPricing.sol";
import {IReserve} from "contracts/interfaces/IReserve.sol";
import {WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";

///////////////////////////////////////////////////////////
//                         CODEX                         //
///////////////////////////////////////////////////////////
struct CodexData {
    uint256 entryType;
    address author;
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
    uint256 fees;
    uint256 referrerFeesShare;
    uint256 lockTime;
    string voidMetadata;
}

struct ContractEntry {
    string key;
    address value;
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
    uint256 iteration;
    bytes inputBytes;
    address minter;
    bool assigned;
}

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
struct OpenEditions {
    uint256 closingTime;
    bytes extra;
}

struct IssuerData {
    uint256 balance;
    uint256 iterationsCount;
    bytes metadata;
    uint256 supply;
    OpenEditions openEditions;
    bytes reserves;
    RoyaltyData primarySplit;
    RoyaltyData royaltiesSplit;
    IssuerInfo info;
    bytes onChainData;
}

struct IssuerInfo {
    uint256[] tags;
    bool enabled;
    uint256 lockedSeconds;
    uint256 timestampMinted;
    bool lockPriceForReserves;
    bool hasTickets;
    uint256 pricingId;
    uint256 codexId;
    uint256 inputBytesSize;
}

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
    uint256 amount;
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
