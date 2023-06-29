// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import {WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";

import "contracts/libs/LibCodex.sol";
import "contracts/libs/LibIssuer.sol";
import "contracts/libs/LibPricing.sol";
import "contracts/libs/LibRoyalty.sol";

interface IIssuer {
    struct Config {
        uint256 fees;
        uint256 referrerFeesShare;
        uint256 lockTime;
        string voidMetadata;
    }

    struct UpdateIssuerInput {
        uint256 issuerId;
        LibRoyalty.RoyaltyData primarySplit;
        LibRoyalty.RoyaltyData royaltiesSplit;
        bool enabled;
    }

    struct UpdatePriceInput {
        uint256 issuerId;
        LibPricing.PricingData pricingData;
    }

    struct UpdateReserveInput {
        uint256 issuerId;
        LibReserve.ReserveData[] reserves;
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
        uint256 issuerId;
        bytes inputBytes;
        address referrer;
        bytes reserveInput;
        bool createTicket;
        address recipient;
    }

    struct MintWithTicketInput {
        uint256 issuerId;
        uint256 ticketId;
        bytes inputBytes;
        address recipient;
    }

    function getIssuer(
        uint256 issuerId
    ) external view returns (LibIssuer.IssuerData memory);

    function mintIssuer(MintIssuerInput calldata params) external;

    function mint(MintInput calldata params) external payable;

    function mintWithTicket(MintWithTicketInput calldata params) external;

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);

    function primarySplitInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);

    function setCodex(uint256 issuerId, uint256 codexId) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
