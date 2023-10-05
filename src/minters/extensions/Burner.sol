// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxGenArt721} from "src/interfaces/IFxGenArt721.sol";
import {IFxMintTicket721} from "src/interfaces/IFxMintTicket721.sol";
import {FxMintTicket721} from "src/tokens/FxMintTicket721.sol";

abstract contract Burner {
    address immutable token;
    address immutable ticket;

    constructor(address _token, address _ticket) {
        token = _token;
        ticket = _ticket;
    }

    function redeem(uint256 _tokenId) external {
        address owner = FxMintTicket721(ticket).ownerOf(_tokenId);
        if (msg.sender != owner) revert();
        IFxMintTicket721(ticket).burn(_tokenId);
        IFxGenArt721(token).mint(owner, 1);
    }
}
