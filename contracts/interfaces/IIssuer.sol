// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibIssuer.sol";

import {CodexInput} from "contracts/interfaces/ICodex.sol";
import {PricingData} from "contracts/interfaces/IPricing.sol";
import {ReserveData} from "contracts/interfaces/IReserve.sol";
import {RoyaltyData} from "contracts/interfaces/ISplitsMain.sol";
import {WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";

interface IIssuer {
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
        LibIssuer.OpenEditions openEditions;
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

    function initialize(address _configManager, address _owner, address _genTk) external;

    function mintIssuer(MintIssuerInput calldata params) external;

    function mint(MintInput calldata params) external payable;

    function mintWithTicket(MintWithTicketInput calldata params) external;

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);

    function primarySplitInfo(
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);

    function setCodex(uint256 codexId) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function getIssuer() external view returns (LibIssuer.IssuerData memory);

    function owner() external view returns (address);
}
