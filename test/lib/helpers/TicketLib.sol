// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Vm.sol";

import {FxMintTicket721} from "src/tokens/FxMintTicket721.sol";
import {IFxMintTicket721, MintInfo} from "src/interfaces/IFxMintTicket721.sol";
import {ITicketRedeemer} from "src/interfaces/ITicketRedeemer.sol";
import {MockMinter} from "test/mocks/MockMinter.sol";

library TicketLib {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    modifier prank(address _caller) {
        vm.startPrank(_caller);
        _;
        vm.stopPrank();
    }

    function claim(
        address _claimer,
        address _proxy,
        uint256 _tokenId,
        uint80 _newPrice,
        uint256 _payment
    ) internal prank(_claimer) {
        IFxMintTicket721(_proxy).claim{value: _payment}(_tokenId, _newPrice);
    }

    function deposit(address _depositer, address _proxy, uint256 _tokenId, uint256 _amount) internal prank(_depositer) {
        IFxMintTicket721(_proxy).deposit{value: _amount}(_tokenId);
    }

    function mint(
        address _caller,
        address _minter,
        address _proxy,
        address _to,
        uint256 _amount,
        uint256 _payment
    ) internal prank(_caller) {
        MockMinter(_minter).mint(_proxy, _to, _amount, _payment);
    }

    function redeem(
        address _owner,
        address _redeemer,
        address _token,
        address _to,
        uint256 _ticketId,
        bytes storage _fxParams
    ) internal prank(_owner) {
        ITicketRedeemer(_redeemer).redeem(_token, _to, _ticketId, _fxParams);
    }

    function registerMinters(address _creator, address _proxy, MintInfo[] memory _mintInfo) internal prank(_creator) {
        IFxMintTicket721(_proxy).registerMinters(_mintInfo);
    }

    function setPrice(address _owner, address _proxy, uint256 _tokenId, uint80 _newPrice) internal prank(_owner) {
        IFxMintTicket721(_proxy).setPrice(_tokenId, _newPrice);
    }

    function setApprovalForAll(
        address _owner,
        address _proxy,
        address _operator,
        bool _approval
    ) internal prank(_owner) {
        FxMintTicket721(_proxy).setApprovalForAll(_operator, _approval);
    }

    function transferFrom(
        address _sender,
        address _proxy,
        address _from,
        address _to,
        uint256 _tokenId
    ) internal prank(_sender) {
        FxMintTicket721(_proxy).transferFrom(_from, _to, _tokenId);
    }

    function withdraw(address _caller, address _proxy, address _to) internal prank(_caller) {
        IFxMintTicket721(_proxy).withdraw(_to);
    }

    function isMinter(address _proxy, address _minter) internal view returns (uint8) {
        return IFxMintTicket721(_proxy).minters(_minter);
    }
}
