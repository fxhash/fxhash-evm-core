// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title IFxTicketFactory
 * @notice Manages newly deployed FxMintTicket721 token contracts
 */
interface IFxTicketFactory {
    /**
     * @notice Event emitted when the FxMintTicket721 implementation contract is updated
     * @param _owner Address of the owner updating the implementation contract
     * @param _implementation Address of the new FxMintTicket721 implementation contract
     */
    event ImplementationUpdated(address indexed _owner, address indexed _implementation);

    /**
     * @notice Event emitted when new Mint Ticket is created
     * @param _ticketId ID of the ticket
     * @param _owner Address of ticket owner
     * @param _mintTicket Address of newly deployed FxMintTicket721 token contract
     */
    event TicketCreated(
        uint96 indexed _ticketId, address indexed _owner, address indexed _mintTicket
    );

    /// @notice Error thrown when grace period is less than one day
    error InvalidGracePeriod();

    /// @notice Error thrown when owner is zero address
    error InvalidOwner();

    /// @notice Error thrown when token is zero address
    error InvalidToken();

    /**
     * @notice Creates new Generative Art project
     * @param _owner Address of project owner
     * @param _genArt721 Address of GenArt721 token contract
     * @param _gracePeriod Period time before token enters harberger taxation
     * @param _baseURI Base URI of the token metadata
     */
    function createTicket(
        address _owner,
        address _genArt721,
        uint48 _gracePeriod,
        string calldata _baseURI
    ) external returns (address);

    /**
     * @notice Sets new FxMintTicket721 implementation contract
     * @param _implementation Address of the FxMintTicket721 contract
     */
    function setImplementation(address _implementation) external;

    /// @notice Returns address of current FxMintTicket721 implementation contract
    function implementation() external view returns (address);

    /// @notice Returns counter of latest token ID
    function ticketId() external view returns (uint96);

    /// @notice Mapping of token ID to address of FxMintTicket721 token contract
    function tickets(uint96) external view returns (address);
}
