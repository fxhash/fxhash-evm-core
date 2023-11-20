// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC1155} from "openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {IERC2981} from "openzeppelin/contracts/interfaces/IERC2981.sol";

import {FEE_DENOMINATOR} from "src/utils/Constants.sol";

contract MockERC1155 is ERC1155, IERC2981 {
    constructor() ERC1155("MockERC1155") {}

    function mint(address _to, uint256 _id, uint256 _amount, bytes memory _data) external {
        _mint(_to, _id, _amount, _data);
    }

    function royaltyInfo(
        uint256,
        uint256 _salePrice
    ) external pure override returns (address receiver, uint256 royaltyAmount) {
        royaltyAmount = (_salePrice * 1_000) / FEE_DENOMINATOR;
        return (receiver, royaltyAmount);
    }
}
