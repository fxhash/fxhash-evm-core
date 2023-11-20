// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract MockTicket {
    address internal owner;

    constructor() {
        owner = msg.sender;
    }

    function burn(uint256 /* _tokenId */) external {
        owner = address(0);
    }

    function ownerOf(uint256 /* _tokenId */) external view returns (address) {
        return owner;
    }
}
