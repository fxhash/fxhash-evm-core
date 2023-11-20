// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract MockToken {
    address internal owner;

    constructor() {
        owner = msg.sender;
    }

    function mintParams(address _to, bytes calldata _fxParams) external {}

    function ownerOf(uint256 /* _tokenId */) external view returns (address) {
        return owner;
    }
}
