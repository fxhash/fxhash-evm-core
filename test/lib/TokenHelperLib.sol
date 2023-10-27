// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";

import {IFxGenArt721, MintInfo} from "src/interfaces/IFxGenArt721.sol";
import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";
import {MockMinter} from "test/mocks/MockMinter.sol";

library TokenHelperLib is Test {
    modifier prank(address _caller) {
        vm.startPrank(_caller);
        _;
        vm.stopPrank();
    }

    function _burn(address _owner, address _proxy, uint256 _tokenId) internal prank(_owner) {
        IFxGenArt721(_proxy).burn(_tokenId);
    }

    function _fulfillSeedRequest(
        address _caller,
        address _proxy,
        uint256 _tokenId,
        bytes32 _seed
    ) internal prank(_caller) {
        ISeedConsumer(_proxy).fulfillSeedRequest(_tokenId, _seed);
    }

    function _mint(address _minter, address _proxy, address _to, uint256 _amount, uint256 _payment) internal {
        MockMinter(_minter).mint(_proxy, _to, _amount, _payment);
    }

    function _ownerMint(address _creator, address _proxy, address _to) internal prank(_creator) {
        IFxGenArt721(_proxy).ownerMint(_to);
    }

    function _pause(address _admin, address _proxy) internal prank(_admin) {
        IFxGenArt721(_proxy).pause();
    }

    function _reduceSupply(address _creator, address _proxy, uint120 _supply) internal prank(_creator) {
        IFxGenArt721(_proxy).reduceSupply(_supply);
    }

    function _registerMinters(address _creator, address _proxy, MintInfo[] memory _mintInfo) internal prank(_creator) {
        IFxGenArt721(_proxy).registerMinters(_mintInfo);
    }

    function _setBaseURI(
        address _admin,
        address _proxy,
        string memory _uri,
        bytes memory _signature
    ) internal prank(_admin) {
        IFxGenArt721(_proxy).setBaseURI(_uri, _signature);
    }

    function _setContractURI(
        address _admin,
        address _proxy,
        string memory _uri,
        bytes memory _signature
    ) internal prank(_admin) {
        IFxGenArt721(_proxy).setContractURI(_uri, _signature);
    }

    function _setImageURI(
        address _admin,
        address _proxy,
        string memory _uri,
        bytes memory _signature
    ) internal prank(_admin) {
        IFxGenArt721(_proxy).setImageURI(_uri, _signature);
    }

    function _setRandomizer(address _admin, address _proxy, address _randomizer) internal prank(_admin) {
        IFxGenArt721(_proxy).setRandomizer(_randomizer);
    }

    function _setRenderer(address _admin, address _proxy, address _renderer) internal prank(_admin) {
        IFxGenArt721(_proxy).setRenderer(_renderer);
    }

    function _toggleBurn(address _creator, address _proxy) internal prank(_creator) {
        IFxGenArt721(_proxy).toggleBurn();
    }

    function _toggleMint(address _creator, address _proxy) internal prank(_creator) {
        IFxGenArt721(_proxy).toggleMint();
    }

    function _unpause(address _admin, address _proxy) internal prank(_admin) {
        IFxGenArt721(_proxy).unpause();
    }
}
