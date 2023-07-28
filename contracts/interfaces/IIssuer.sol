// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";

import "contracts/libs/LibCodex.sol";
import "contracts/libs/LibIssuer.sol";
import "contracts/libs/LibPricing.sol";
import "contracts/libs/LibRoyalty.sol";

/**
 * @title Issuer interface
 * @author fxhash
 * @notice The issuer contract is the main contract used to generate the NFT
 * assets. Issuer contracts are factory-instanciated for every project, and 
 * specify the details of a project, as defined by its author(s).
 */
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

    function initialize(address _configManager, address _owner, address _genTk) external;

    /**
     * Publish a new project (issuer) to the contract
     * @param params describes the Issuer to be minted
     * 
     * TODO this needs to be removed in favor of factory instanciation
     */
    function mintIssuer(MintIssuerInput calldata params) external;

    /**
     * Mint a new iteration from the project. This is a generic EP which acts as
     * a main entry to minting, regardless of the cases in which the mint as to
     * occur.
     * Supports:
     * - reserve/non-reserve
     * - params: 
     *   - generates a ticket
     *   - mint directly
     * @param params information related to the mint, eventually input data
     */
    function mint(MintInput calldata params) external payable;

    /**
     * Can be used to exchange a mint ticket for an iteration of the project.
     * @param params information related to the mint & the ticket
     */
    function mintWithTicket(MintWithTicketInput calldata params) external;

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);

    function primarySplitInfo(
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);

    /**
     * Updates the codex ID associated with the project, effectively updating
     * the code behind the project.
     * @param codexId identifier in the codex contract
     * 
     * TODO:
     *  - the codex has updateIssuerCodexRequest & updateIssuerCodexRequest, 
     *    which serve the same purpose (or should)
     *  - the update mechanism should support request & approval pattern
     */
    function setCodex(uint256 codexId) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function getIssuer() external view returns (LibIssuer.IssuerData memory);

    function owner() external view returns (address);
}
