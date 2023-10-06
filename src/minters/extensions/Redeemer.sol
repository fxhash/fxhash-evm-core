// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {FxMintTicket721} from "src/tokens/FxMintTicket721.sol";
import {IFxGenArt721} from "src/interfaces/IFxGenArt721.sol";
import {IRedeemer} from "src/interfaces/IRedeemer.sol";

contract Redeemer is IRedeemer {
    function burn(address _ticket, uint256 _tokenId) external {
        // Reverts if caller is not owner of ticket
        address owner = FxMintTicket721(_ticket).ownerOf(_tokenId);
        if (msg.sender != owner) revert NotAuthorized();
        // Reverts if token contract does not exist
        address token = FxMintTicket721(_ticket).genArt721();
        if (token == address(0)) revert InvalidToken();

        // Burns ticket
        FxMintTicket721(_ticket).burn(_tokenId);
        // Mints new token to caller
        IFxGenArt721(token).redeem(owner);

        // Emits event when token has been redeemed
        emit Redeemed(_ticket, _tokenId, owner, token);
    }
}
