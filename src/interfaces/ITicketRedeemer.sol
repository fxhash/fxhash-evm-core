// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IMinter} from "src/interfaces/IMinter.sol";
import {ReserveInfo} from "src/lib/Structs.sol";

/**
 * @title ITicketRedeemer
 * @author fx(hash)
 * @notice Minter for redeeming FxGenArt721 tokens by burning FxMintTicket721 tokens
 */
interface ITicketRedeemer is IMinter {
    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when the mint details are set for a ticket contract
     * @param _ticket Address of the ticket contract
     * @param _token Address of the token contract that can be redeemed through the ticket
     */
    event MintDetailsSet(address indexed _ticket, address indexed _token);

    /**
     * @notice Event emitted when a ticket is burned and a new token is minted
     * @param _ticket Address of the ticket contract
     * @param _tokenId ID of the token being burned
     * @param _owner Address of the owner receiving the token
     * @param _token Address of the token being minted
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
     * @inheritdoc IMinter
     * @dev Mint Details: ticket contract address
     */
    function setMintDetails(ReserveInfo calldata _reserveInfo, bytes calldata _mintDetails) external;

    /**
     * @notice Mapping of FxGenArt721 token address to FxMintTicket721 token address
     */
    function tickets(address) external view returns (address);
}
