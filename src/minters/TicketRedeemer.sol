// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Ownable} from "solady/src/auth/Ownable.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";

import {IERC721} from "openzeppelin/contracts/interfaces/IERC721.sol";
import {IFxGenArt721, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFxMintTicket721} from "src/interfaces/IFxMintTicket721.sol";
import {ITicketRedeemer} from "src/interfaces/ITicketRedeemer.sol";

/**
 * @title TicketRedeemer
 * @author fx(hash)
 * @dev See the documentation in {ITicketRedeemer}
 */
contract TicketRedeemer is ITicketRedeemer, Ownable, Pausable {
    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc ITicketRedeemer
     */
    mapping(address => address) public tickets;

    /*//////////////////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(address _initialOwner) {
        _initializeOwner(_initialOwner);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc ITicketRedeemer
     */
    function redeem(address _token, address _to, uint256 _ticketId, bytes calldata _fxParams) external whenNotPaused {
        address ticket = tickets[_token];
        // Reverts if ticket contract does not exist
        if (ticket == address(0)) revert InvalidToken();
        address owner = IERC721(ticket).ownerOf(_ticketId);
        // Reverts if caller is not owner of token
        if (msg.sender != owner) revert NotAuthorized();
        if (_to == address(0)) revert ZeroAddress();

        // Burns ticket
        IFxMintTicket721(ticket).burn(_ticketId);
        // Mints new fxParams token to caller
        IFxGenArt721(_token).mintParams(_to, _fxParams);

        // Emits event when token has been redeemed
        emit Redeemed(ticket, _ticketId, owner, _token);
    }

    /**
     * @inheritdoc ITicketRedeemer
     */
    function setMintDetails(ReserveInfo calldata, bytes calldata _mintDetails) external whenNotPaused {
        // Decodes ticket address from mint data
        address ticket = abi.decode(_mintDetails, (address));
        // Reverts if ticket address has alread been set
        if (tickets[msg.sender] != address(0)) revert AlreadySet();
        tickets[msg.sender] = ticket;

        // Emits event when mint details have been set
        emit MintDetailsSet(ticket, msg.sender);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc ITicketRedeemer
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @inheritdoc ITicketRedeemer
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}
