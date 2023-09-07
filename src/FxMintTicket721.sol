// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IFxMintTicket721} from "src/interfaces/IFxMintTicket721.sol";
import {
    ERC721,
    ERC721URIStorage
} from "openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Upgradeable} from
    "openzeppelin-upgradeable/contracts/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";

contract FxMintTicket721 is IFxMintTicket721, ERC721URIStorage {
    constructor() ERC721("FxMintTicket721", "TICKET") {}

    function mint(address _to, uint256 _amount) external {}

    function burn(uint256 _tokenId) external {}
}
