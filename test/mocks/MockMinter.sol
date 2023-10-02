// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {FxMintTicket721} from "src/tokens/FxMintTicket721.sol";
import {IFxGenArt721, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFxMintTicket721} from "src/interfaces/IFxMintTicket721.sol";

contract MockMinter {
    function setMintDetails(ReserveInfo calldata, bytes calldata) external {}

    function mintToken(address _token, address _to, uint256 _amount) external {
        IFxGenArt721(_token).mint(_to, _amount);
    }

    function mintTicket(address _ticket, address _to, uint256 _amount, uint256 _payment) external {
        IFxMintTicket721(_ticket).mint(_to, _amount, _payment);
    }

    function burnTicket(address _ticket, uint256 _tokenId) external {
        address owner = FxMintTicket721(_ticket).ownerOf(_tokenId);
        IFxMintTicket721(_ticket).burn(_tokenId);
        address genArt721Proxy = IFxMintTicket721(_ticket).genArt721();
        IFxGenArt721(genArt721Proxy).mint(owner, 1);
    }
}
