// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

contract MockERC1155 is ERC1155, IERC2981 {
    constructor() ERC1155("MockERC1155") {}

    function mint(address to, uint256 id, uint256 amount, bytes memory data) external {
        super._mint(to, id, amount, data);
    }

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external pure override returns (address receiver, uint256 royaltyAmount) {
        return (receiver, (salePrice * 1000) / 10000);
    }
}
