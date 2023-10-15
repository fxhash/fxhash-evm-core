// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {FxMintTicket721} from "src/tokens/FxMintTicket721.sol";

import {IFxGenArt721, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IMinter} from "src/interfaces/IMinter.sol";
import {ITicketRedeemer} from "src/interfaces/ITicketRedeemer.sol";

/**
 * @title TicketRedeemer
 * @author fxhash
 * @dev See the documentation in {ITicketRedeemer}
 */
contract TicketRedeemer is ITicketRedeemer {
    /**
     * @inheritdoc ITicketRedeemer
     */
    mapping(address => address) public tokens;

    /**
     * @inheritdoc ITicketRedeemer
     */
    function setMintDetails(ReserveInfo calldata, bytes calldata _mintData) external {
        // Decodes ticket address from mint data
        address ticket = abi.decode(_mintData, (address));
        // Reverts if ticket address has alread been set
        if (tokens[ticket] != address(0)) revert AlreadySet();
        tokens[ticket] = msg.sender;

        // Emits event when mint details have been set
        emit MintDetailsSet(ticket, msg.sender);
    }

    /**
     * @inheritdoc ITicketRedeemer
     */
    function redeem(address _ticket, uint256 _tokenId, bytes calldata _fxParams) external {
        // Reverts if caller is not owner of ticket
        address owner = FxMintTicket721(_ticket).ownerOf(_tokenId);
        if (msg.sender != owner) revert NotAuthorized();
        // Reverts if token contract does not exist
        address token = tokens[_ticket];
        if (token == address(0)) revert InvalidToken();

        // Burns ticket
        FxMintTicket721(_ticket).burn(_tokenId);
        // Mints new fxParams token to caller
        IFxGenArt721(token).mintParams(owner, _fxParams);

        // Emits event when token has been redeemed
        emit Redeemed(_ticket, _tokenId, owner, token);
    }
}
