// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MintInfo} from "src/interfaces/IFxGenArt721.sol";

/**
 * @title IFxTicketFactory
 * @notice Manages newly deployed FxMintTicket721 token contracts
 */
interface IFxTicketFactory {
    /**
     * @notice Event emitted when the minimum grace period is updated
     * @param _owner Address of the contract owner
     * @param _gracePeriod Time duration of the new grace period
     */
    event GracePeriodUpdated(address indexed _owner, uint48 indexed _gracePeriod);

    /**
     * @notice Event emitted when the FxMintTicket721 implementation contract is updated
     * @param _owner Address of the owner updating the implementation contract
     * @param _implementation Address of the new FxMintTicket721 implementation contract
     */
    event ImplementationUpdated(address indexed _owner, address indexed _implementation);

    /**
     * @notice Event emitted when new Mint Ticket is created
     * @param _ticketId ID of the ticket
     * @param _mintTicket Address of newly deployed FxMintTicket721 token contract
     * @param _owner Address of contract owner
     */
    event TicketCreated(uint96 indexed _ticketId, address indexed _mintTicket, address indexed _owner);

    /// @notice Error thrown when grace period is less than one day
    error InvalidGracePeriod();

    /// @notice Error thrown when owner is zero address
    error InvalidOwner();

    /// @notice Error thrown when redeemer is zero address
    error InvalidRedeemer();

    /// @notice Error thrown when token is zero address
    error InvalidToken();

    /**
     * @notice Creates new Generative Art project
     * @param _owner Address of project owner
     * @param _genArt721 Address of GenArt721 token contract
     * @param _redeemer Address of TicketRedeemer minter contract
     * @param _gracePeriod Period time before token enters harberger taxation
     * @param _mintInfo List of authorized minter contracts and their reserves
     */
    function createTicket(
        address _owner,
        address _genArt721,
        address _redeemer,
        uint48 _gracePeriod,
        MintInfo[] calldata _mintInfo
    ) external returns (address);

    /**
     * @notice Sets new FxMintTicket721 implementation contract
     * @param _implementation Address of the FxMintTicket721 contract
     */
    function setImplementation(address _implementation) external;

    /**
     * @notice Sets the new minimum grace period
     * @param _gracePeriod Minimum time duration before a ticket enters harberger taxation
     */
    function setGracePeriod(uint48 _gracePeriod) external;

    /// @notice Returns address of current FxMintTicket721 implementation contract
    function implementation() external view returns (address);

    /// @notice Mapping of deployer address to nonce value for precomputing ticket address
    function nonces(address _deployer) external view returns (uint256);

    /// @notice Returns the minimum duration of time before a ticket enters harberger taxation
    function minGracePeriod() external view returns (uint48);

    /// @notice Returns counter of latest token ID
    function ticketId() external view returns (uint48);

    /// @notice Mapping of token ID to address of FxMintTicket721 token contract
    function tickets(uint48 _ticketId) external view returns (address);
}
