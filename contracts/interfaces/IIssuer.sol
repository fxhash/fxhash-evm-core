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

    /**
     * Generic entry point to update the details of a project. Canonly be called
     * by the author(s) of the project.
     * @param params update details
     */
    function updateIssuer(UpdateIssuerInput calldata params) external;

    /**
     * Author(s) can update the pricing of their projects.
     * @param pricingData new pricing data (method, details)
     */
    function updatePrice(LibPricing.PricingData calldata pricingData) external;

    /**
     * Author(s) can update the reserves of their projects. The full reservers
     * are replaced by the new ones provided.
     * To avoid race-condition issues, the issuer must be disabled for the
     * reserves to be updated.
     * @param reserves the whole new reserve details
     */
    function updateReserve(LibReserve.ReserveData[] calldata reserves) external;

    /**
     * Author(s) can burn an issuer completely, as long as not iteration have
     * been minted at the time of burn. Everything related to the issuer should
     * be deleted when burnt.
     */
    function burn() external;

    /**
     * Author(s) can burn a given number of editions from the supply, as long as
     * those editions are still available to be minted. Once burnt, the supply 
     * cannot be increased.
     * Open-edition projects cannot have their supply burnt.
     * @param amount number of editions to be burnt from the supply
     */
    function burnSupply(uint256 amount) external;

    /**
     * Moderators can update a list of tags associated to a project, to better
     * classify the body of work on the platform using fxhash internal 
     * classification system.
     * @param tags a list of identifier mapping to the labels to assciate with 
     * the project
     */
    function updateIssuerMod(uint256[] calldata tags) external;

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
