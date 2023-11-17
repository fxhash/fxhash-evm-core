// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract MockTicket {
    address internal owner = msg.sender;

    function burn(uint256 _tokenId) external {}

    function ownerOf(uint256 /* _tokenId */) external view returns (address) {
        return owner;
    }
}
