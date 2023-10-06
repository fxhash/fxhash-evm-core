// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {FxMintTicket721} from "src/tokens/FxMintTicket721.sol";
import {IFxGenArt721} from "src/interfaces/IFxGenArt721.sol";
import {IRedeemer} from "src/interfaces/IRedeemer.sol";

contract Redeemer is IRedeemer {
    function redeem(address _ticket, uint256 _tokenId) external {
        address owner = FxMintTicket721(_ticket).ownerOf(_tokenId);
        if (msg.sender != owner) revert NotAuthorized();
        address token = FxMintTicket721(_ticket).genArt721();
        if (token == address(0)) revert InvalidToken();

        FxMintTicket721(_ticket).burn(_tokenId);
        IFxGenArt721(token).claim(owner);

        emit Redeemed(_ticket, _tokenId, owner, token);
    }
}
