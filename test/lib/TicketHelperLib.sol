// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {FxMintTicket721} from "src/tokens/FxMintTicket721.sol";
import {IFxMintTicket721, MintInfo} from "src/interfaces/IFxMintTicket721.sol";
import {ITicketRedeemer} from "src/interfaces/ITicketRedeemer.sol";
import {MockMinter} from "test/mocks/MockMinter.sol";

library TicketHelperLib {
    function _claim(address _proxy, uint256 _tokenId, uint80 _newPrice, uint256 _payment) internal {
        IFxMintTicket721(_proxy).claim{value: _payment}(_tokenId, _newPrice);
    }

    function _deposit(address _proxy, uint256 _tokenId, uint256 _amount) internal {
        IFxMintTicket721(_proxy).deposit{value: _amount}(_tokenId);
    }

    function _mint(address _minter, address _proxy, address _to, uint256 _amount, uint256 _payment) internal {
        MockMinter(_minter).mint(_proxy, _to, _amount, _payment);
    }

    function _redeem(address _redeemer, address _ticket, uint256 _tokenId, bytes storage _fxParams) internal {
        ITicketRedeemer(_redeemer).redeem(_ticket, _tokenId, _fxParams);
    }

    function _registerMinters(address _proxy, MintInfo[] memory _mintInfo) internal {
        IFxMintTicket721(_proxy).registerMinters(_mintInfo);
    }

    function _setPrice(address _proxy, uint256 _tokenId, uint80 _newPrice) internal {
        IFxMintTicket721(_proxy).setPrice(_tokenId, _newPrice);
    }

    function _setApprovalForAll(address _proxy, address _operator, bool _approval) internal {
        FxMintTicket721(_proxy).setApprovalForAll(_operator, _approval);
    }

    function _transferFrom(address _proxy, address _from, address _to, uint256 _tokenId) internal {
        FxMintTicket721(_proxy).transferFrom(_from, _to, _tokenId);
    }

    function _withdraw(address _proxy, address _to) internal {
        IFxMintTicket721(_proxy).withdraw(_to);
    }

    function _isMinter(address _proxy, address _minter) internal view returns (bool) {
        return IFxMintTicket721(_proxy).minters(_minter);
    }
}
