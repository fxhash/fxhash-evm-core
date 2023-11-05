// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract MockTicket {
    address internal owner = msg.sender;

    function burn(uint256) external {}

    function ownerOf(uint256) external returns (address) {
        return owner;
    }
}
