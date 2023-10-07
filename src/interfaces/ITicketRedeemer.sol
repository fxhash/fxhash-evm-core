// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IMinter} from "src/interfaces/IMinter.sol";

/**
 * @title ITicketRedeemer
 * @notice Minter contract for redeeming mint tickets to mint a FxGenArt721 token
 */
interface ITicketRedeemer is IMinter {
    /**
     * @dev Emitted when the mint details are set for a ticket contract
     * @param _ticket The address of the ticket contract
     * @param _token The address of the token that can be minted by the ticket contract
     */
    event MintDetailsSet(address indexed _ticket, address indexed _token);

    /**
     * @dev Emitted when a ticket is redeemed and a new token is minted
     * @param _ticket The address of the ticket contract
     * @param _tokenId The ID of the ticket token that is burned
     * @param _owner The address of the owner of the new token
     * @param _token The address of the token that is minted
     */
    event Redeemed(address indexed _ticket, uint256 indexed _tokenId, address indexed _owner, address _token);

    /**
     * @dev Throws an error indicating that the mint details are already set for a ticket contract
     */
    error AlreadySet();
    /**
     * @dev Throws an error indicating that the token is invalid
     */
    error InvalidToken();
    /**
     * @dev Throws an error indicating that the caller is not authorized
     */
    error NotAuthorized();

    /**
     * @notice Burns a ticket and mints a new token to the caller
     * @param _ticket The address of the ticket contract
     * @param _tokenId The ID of the ticket token to burn
     */
    function redeem(address _ticket, uint256 _tokenId) external;

    /**
     * @notice A mapping of tickets to the tokens they can mint
     * @param _ticket The address of the ticket contract
     */
    function tokens(address _ticket) external view returns (address);
}
