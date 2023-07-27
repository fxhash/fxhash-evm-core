// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";

///////////////////////////////////////////////////////////
//                         CODEX                         //
///////////////////////////////////////////////////////////

/// @param entryType Storage type of JS scripts (Ex: IPFS, Arweave, Scripty, etc.)
/// @param artist Address of author
/// @param locked Status of codex entry
/// @param issuer Address of Issuer contract
/// @param pointer Offchain URI of pointer to raw code
/// @param scripts Onchain list of script requests
struct CodexInfo {
    uint88 entryType;
    address author;
    bool locked;
    address issuer;
    string pointer;
    WrappedScriptRequest[] scripts;
}

///////////////////////////////////////////////////////////
//                     CONFIGURATION                     //
///////////////////////////////////////////////////////////

/// @param feeShare Share fee out of 10000 basis points
/// @param referrerShare Referrer fee share out of 10000 basis points
/// @param lockTime Time duration of locked
/// @param defaultMetadata Default URI of metadata
struct ConfigInfo {
    uint64 feeShare;
    uint64 referrerShare;
    uint128 lockTime;
    string defaultMetadata;
}

///////////////////////////////////////////////////////////
//                       CYCLES                          //
///////////////////////////////////////////////////////////

/// @param openingDuration Duration of opening time
/// @param closingDuration Duration of closing time
/// @param startTimestamp Starting timestamp
struct CycleInfo {
    uint64 openingDuration;
    uint64 closingDuration;
    uint128 startTimestamp;
}

///////////////////////////////////////////////////////////
//                         GENTK                         //
///////////////////////////////////////////////////////////

/// @param fxParams Randon sequence of string bytes in fixed length
/// @param seed Hash of revealed seed
/// @param offChainPointer URI of offchain metadata pointer
/// @param onChainAttributes List of key value mappings of onchain metadata storage
struct GenerativeInfo {
    bytes fxParams;
    bytes32 seed;
    string offChainPointer;
    MetadataInfo[] onChainAttributes;
}

///////////////////////////////////////////////////////////
//                         ISSUER                        //
///////////////////////////////////////////////////////////

/// @param projectInfo Project information
/// @param mintInfo Mint information
/// @param SaleInfo Sale information
/// @param ReserveInfo List of Reserve information
struct IssuserInfo {
    ProjectInfo projectInfo;
    MintInfo mintInfo;
    SaleInfo saleInfo;
    ReserveInfo[] reserves;
}

/// @param enabled Active status of project
/// @param pricingId ID of pricing type
/// @param supply Maximum supply of tokens
/// @param codexId ID of codex info
/// @param metadata Bytes-encoded metadata
/// @param labels List of labels describing project
struct ProjectInfo {
    bool enabled;
    uint8 pricingId;
    uint112 supply;
    uint112 codexId;
    bytes metadata;
    uint16[] labels;
}

/// @param inputSize Size of input bytes
/// @param lockedTime Timestamp of when minting is locked
/// @param closingTime Timestamp of when mint closes
/// @param lockedReserve Status of locking current price for reserves
/// @param hasTickets Status of mint tickets
struct MintInfo {
    uint32 inputSize;
    uint104 lockedTime;
    uint104 closingTime;
    bool lockedReserve;
    bool hasTickets;
}

/// @param primarySplit Royalty splits of primary sales
/// @param secondarySplit Royalty splits of secondary sales
struct SaleInfo {
    RoyaltyInfo primarySplit;
    RoyaltyInfo secondarySplit;
}

///////////////////////////////////////////////////////////
//                      MARKETPLACE                      //
///////////////////////////////////////////////////////////

enum Token {
    ETH,
    ERC20,
    ERC721,
    ERC1155
}

/// @param token Type of token standard
/// @param contractAddr Address of token contract
/// @param id ID of the token (ERC721 & ERC1155)
/// @param amount Amount of tokens (ETH, ERC20 && ERC155)
struct Currency {
    Token token;
    address contractAddr;
    uint40 id;
    uint48 amount;
}

/// @param contractAddr Address of the token contract
/// @param tokenId ID of the token asset
struct Asset {
    address contractAddr;
    uint96 tokenId;
}

/// @param asset Token asset info
/// @param currency Currency info
/// @param seller Address of the seller
struct Listing {
    Asset asset;
    Currency currency;
    address seller;
}

/// @param assets List of token assets
/// @param currency Currency info
/// @param seller Address of the buyer
struct Offer {
    Asset[] assets;
    Currency currency;
    address buyer;
}

///////////////////////////////////////////////////////////
//                    MINT PASS GROUP                    //
///////////////////////////////////////////////////////////

/// @param amount Number of tokens minted
/// @param consumer Address of the consumer
/// @param issuer Address of the Issuer contract
struct MintPassInfo {
    uint96 amount;
    address consumer;
    address issuer;
}

///////////////////////////////////////////////////////////
//                      MINT TICKET                      //
///////////////////////////////////////////////////////////

/// @param createdAt Timestamp of when ticket was created
/// @param minter Address of the minter
/// @param startTime Timestamp of starting point for calculating taxation period
/// @param taxesLocked Amount of taxes locked up
/// @param issuer Address of the Issuer contract
/// @param price Price of the ticket
/// @param gracePeriod Initial period after ticket is minted
/// @param pointer URI pointer of ticket metadata
struct MintTicketInfo {
    uint96 createdAt;
    address minter;
    uint48 startTime;
    uint48 taxesLocked;
    address issuer;
    uint128 price;
    uint128 gracePeriod;
    string pointer;
}

///////////////////////////////////////////////////////////
//                       MODERATION                      //
///////////////////////////////////////////////////////////

/// @param state Possible states of moderation for users
/// @param reason Possible reasons of moderation for users
struct UserModerationInfo {
    uint128 state;
    uint128 reason;
}

/// @param state Possible states of moderation for tokens
/// @param reason Possible reasons of moderation for tokens
struct TokenModerationInfo {
    uint128 state;
    uint128 reason;
}

/// @param authorizations List of authorizations granted to moderator
/// @param share Amount of shares to be paid to moderator
struct ModeratorInfo {
    uint16[] authorizations;
    uint256 share;
}

///////////////////////////////////////////////////////////
//                ONCHAIN METADATA MANAGER               //
///////////////////////////////////////////////////////////

/// @param key Attribute key of JSON field
/// @param value Attribute value of JSON field
struct MetadataInfo {
    string key;
    string value;
}

///////////////////////////////////////////////////////////
//                       PRICING                         //
///////////////////////////////////////////////////////////

/// @param contractAddr Address of the contract
/// @param lockedReserve Status of locking current price for reserves
/// @param startTime Timestamp of when minting opens
/// @param price Current price amount
/// @param details Payload of the pricing method
struct PricingInfo {
    address contractAddr;
    bool lockedReserve;
    uint88 startTime;
    uint256 price;
    bytes pricingDetails;
}

///////////////////////////////////////////////////////////
//                         RANDOMIZER                    //
///////////////////////////////////////////////////////////

/// @param issuer Address of the Issuer contract
/// @param tokenId ID of the token
struct KeyInfo {
    address issuer;
    uint96 tokenId;
}

/// @param serialId ID of the generated sequence
/// @param revealed Status of whether token has been revealed
struct SeedInfo {
    uint248 serialId;
    bool revealed;
}

///////////////////////////////////////////////////////////
//                         RESERVE                       //
///////////////////////////////////////////////////////////

/// @param enabled Status of the reserve
/// @param supply Current supply of reserved tokens
/// @param minter Address of the minter
/// @param reserveType Type of the reserve method
/// @param contractAddr Address of the Reserve contract
/// @param whitelist List of the whitelisted addresses
/// @param reserves List of reserved addresses
struct ReserveInfo {
    bool enabled;
    uint88 supply;
    address minter;
    uint96 reserveType;
    address contractAddr;
    WhitelistInfo[] whitelist;
    bytes reserves;
}

/// @param account Address of the whitelisted account
/// @param amount Amount of the tokens reserved for the account
struct WhitelistInfo {
    address account;
    uint96 amount;
}

///////////////////////////////////////////////////////////
//                       ROYALTY                         //
///////////////////////////////////////////////////////////

/// @param percent Percentage amount of royalties
/// @param receiver Address of receiver
struct RoyaltyInfo {
    uint96 percent;
    address receiver;
}
