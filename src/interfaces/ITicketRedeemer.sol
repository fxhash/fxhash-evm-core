// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IMinter} from "src/interfaces/IMinter.sol";

/**
 * @title ITicketRedeemer
 * @author fxhash
 * @notice Minter for redeeming FxGenArt721 tokens by burning FxMintTicket721 tokens
 */
interface ITicketRedeemer is IMinter {
    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when the mint details are set for a ticket contract
     * @param _ticket Address of the ticket contract
     * @param _token Address of the token that can be minted by the ticket contract
     */
    event MintDetailsSet(address indexed _ticket, address indexed _token);

    /**
     * @notice Event emitted when a ticket is redeemed and a new token is minted
     * @param _ticket The address of the ticket contract
     * @param _tokenId The ID of the ticket token that is burned
     * @param _owner The address of the owner of the new token
     * @param _token The address of the token that is minted
     */
    event Redeemed(address indexed _ticket, uint256 indexed _tokenId, address indexed _owner, address _token);

    /*//////////////////////////////////////////////////////////////////////////
                                  ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Error thrown when mint details are already set for a ticket contract
     */
    error AlreadySet();

    /**
     * @notice Error thrown when token address is invalid
     */
    error InvalidToken();

    /**
     * @notice Error thrown when the caller is not authorized
     */
    error NotAuthorized();

    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Burns a ticket and mints a new token to the caller
     * @param _ticket Address of the ticket contract
     * @param _tokenId ID of the ticket token to burn
     * @param _fxParams Random sequence of fixed-length bytes used for token input
     */
    function redeem(address _ticket, uint256 _tokenId, bytes calldata _fxParams) external;

    /**
     * @notice Mapping of FxGenArt721 token address to FxMintTicket721 token address
     */
    function tokens(address) external view returns (address);
}
