// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";

contract MockERC721 is ERC721, IERC2981 {
    address royaltyReceiver;

    constructor(address _royaltyReceiver) ERC721("MockERC721", "MERC721") {
        royaltyReceiver = _royaltyReceiver;
    }

    function mint(address to, uint256 tokenId) external {
        super._mint(to, tokenId);
    }

    function royaltyInfo(uint256, /* tokenId */ uint256 salePrice)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        return (royaltyReceiver, (salePrice * 1000) / 10_000);
    }
}
