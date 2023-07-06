// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";

import "contracts/libs/LibCodex.sol";
import "contracts/libs/LibIssuer.sol";
import "contracts/libs/LibPricing.sol";
import "contracts/libs/LibRoyalty.sol";

interface IIssuer {
    struct UpdateIssuerInput {
        LibRoyalty.RoyaltyData primarySplit;
        LibRoyalty.RoyaltyData royaltiesSplit;
        bool enabled;
    }

    struct MintTicketSettings {
        uint256 gracingPeriod; //in days
        string metadata;
    }

    struct MintIssuerInput {
        LibCodex.CodexInput codex;
        bytes metadata;
        uint256 inputBytesSize;
        uint256 amount;
        LibIssuer.OpenEditions openEditions;
        MintTicketSettings mintTicketSettings;
        LibReserve.ReserveData[] reserves;
        LibPricing.PricingData pricing;
        LibRoyalty.RoyaltyData primarySplit;
        LibRoyalty.RoyaltyData royaltiesSplit;
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

    function mintIssuer(
        MintIssuerInput calldata params,
        bytes calldata signature
    ) external;

    function mint(
        MintInput calldata params,
        bytes calldata signature
    ) external payable;

    function mintWithTicket(
        MintWithTicketInput calldata params,
        bytes calldata signature
    ) external;

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
