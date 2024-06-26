// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Vm.sol";

import {FxGenArt721} from "src/tokens/FxGenArt721.sol";
import {IFxGenArt721, MintInfo} from "src/interfaces/IFxGenArt721.sol";
import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";
import {MockMinter} from "test/mocks/MockMinter.sol";

library TokenLib {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    modifier prank(address _caller) {
        vm.startPrank(_caller);
        _;
        vm.stopPrank();
    }

    function burn(address _owner, address _proxy, uint256 _tokenId) internal prank(_owner) {
        IFxGenArt721(_proxy).burn(_tokenId);
    }

    function fulfillSeedRequest(
        address _caller,
        address _proxy,
        uint256 _tokenId,
        bytes32 _seed
    ) internal prank(_caller) {
        ISeedConsumer(_proxy).fulfillSeedRequest(_tokenId, _seed);
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

    function ownerMint(address _creator, address _proxy, address _to) internal prank(_creator) {
        IFxGenArt721(_proxy).ownerMint(_to);
    }

    function pause(address _admin, address _proxy) internal prank(_admin) {
        IFxGenArt721(_proxy).pause();
    }

    function reduceSupply(address _creator, address _proxy, uint120 _supply) internal prank(_creator) {
        IFxGenArt721(_proxy).reduceSupply(_supply);
    }

    function registerMinters(address _creator, address _proxy, MintInfo[] memory _mintInfo) internal prank(_creator) {
        IFxGenArt721(_proxy).registerMinters(_mintInfo);
    }

    function setBaseRoyalties(
        address _admin,
        address _proxy,
        address[] memory _receivers,
        uint32[] memory _allocations,
        uint96 _basisPoints
    ) internal prank(_admin) {
        IFxGenArt721(_proxy).setBaseRoyalties(_receivers, _allocations, _basisPoints);
    }

    function setBaseURI(address _admin, address _proxy, bytes memory _uri) internal prank(_admin) {
        IFxGenArt721(_proxy).setBaseURI(_uri);
    }

    function setBurnEnabled(address _creator, address _proxy, bool _flag) internal prank(_creator) {
        IFxGenArt721(_proxy).setBurnEnabled(_flag);
    }

    function setMintEnabled(address _creator, address _proxy, bool _flag) internal prank(_creator) {
        IFxGenArt721(_proxy).setMintEnabled(_flag);
    }

    function setOnchainPointer(
        address _admin,
        address _proxy,
        bytes memory _onchainData,
        bytes memory _signature
    ) internal prank(_admin) {
        IFxGenArt721(_proxy).setOnchainPointer(_onchainData, _signature);
    }

    function setRandomizer(address _admin, address _proxy, address _randomizer) internal prank(_admin) {
        IFxGenArt721(_proxy).setRandomizer(_randomizer);
    }

    function setRenderer(
        address _admin,
        address _proxy,
        address _renderer,
        bytes memory _signature
    ) internal prank(_admin) {
        IFxGenArt721(_proxy).setRenderer(_renderer, _signature);
    }

    function setTags(address _admin, address _proxy, uint256[] memory _tagIds) internal prank(_admin) {
        IFxGenArt721(_proxy).setTags(_tagIds);
    }

    function transferOwnership(address _owner, address _proxy, address _account) internal prank(_owner) {
        FxGenArt721(_proxy).transferOwnership(_account);
    }

    function unpause(address _admin, address _proxy) internal prank(_admin) {
        IFxGenArt721(_proxy).unpause();
    }

    function isMinter(address _proxy, address _minter) internal view returns (bool) {
        return IFxGenArt721(_proxy).isMinter(_minter);
    }
}
