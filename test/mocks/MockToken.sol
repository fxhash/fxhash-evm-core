// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC721} from "openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockToken is ERC721 {
    address internal owner;

    constructor() ERC721("", "") {
        owner = msg.sender;
    }

    function mintParams(address _to, bytes calldata _fxParams) external {}

    function name() public pure override returns (string memory) {
        return "name";
    }

    function symbol() public pure override returns (string memory) {
        return "symbol";
    }

    function ownerOf(uint256 /* _tokenId */) public view override returns (address) {
        return owner;
    }
}
