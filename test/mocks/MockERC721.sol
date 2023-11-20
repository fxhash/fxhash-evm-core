// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC721} from "openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC2981} from "openzeppelin/contracts/interfaces/IERC2981.sol";

import {FEE_DENOMINATOR} from "src/utils/Constants.sol";

contract MockERC721 is ERC721, IERC2981 {
    constructor() ERC721("MockERC721", "ERC721") {}

    function mint(address _to, uint256 _tokenId) external {
        _mint(_to, _tokenId);
    }

    function royaltyInfo(
        uint256,
        uint256 _salePrice
    ) external pure override returns (address receiver, uint256 royaltyAmount) {
        royaltyAmount = (_salePrice * 1_000) / FEE_DENOMINATOR;
        return (receiver, royaltyAmount);
    }
}
