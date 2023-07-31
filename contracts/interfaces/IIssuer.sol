// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {CodexInput} from "contracts/interfaces/ICodex.sol";
import {PricingData} from "contracts/interfaces/IPricing.sol";
import {ReserveData} from "contracts/interfaces/IReserve.sol";
import {RoyaltyData} from "contracts/interfaces/IRoyalties.sol";
import {WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";

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

interface IIssuer {
    function initialize(address _configManager, address _owner, address _genTk) external;

    function mintIssuer(MintIssuerInput calldata params) external;

    function mint(MintInput calldata params) external payable;

    function mintWithTicket(MintWithTicketInput calldata params) external;

    function primarySplitInfo(
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);

    function setCodex(uint256 codexId) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function getIssuer() external view returns (IssuerData memory);

    function owner() external view returns (address);
}
