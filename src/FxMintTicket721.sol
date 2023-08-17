// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IFxMintTicket721} from "src/interfaces/IFxMintTicket721.sol";
import {
    ERC721URIStorageUpgradeable,
    ERC721Upgradeable
} from "openzeppelin-upgradeable/contracts/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";

contract FxMintTicket721 is IFxMintTicket721, ERC721URIStorageUpgradeable {
    function mint(uint256, address) external {}

    function burn(uint256) external {}
}
