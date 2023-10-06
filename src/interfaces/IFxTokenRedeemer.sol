// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IFxTokenRedeemer {
    error InvalidToken();
    error NotAuthorized();

    event Redeemed(address indexed ticket, uint256 indexed tokenId, address indexed owner, address token);

    function burn(address _ticket, uint256 _tokenId) external;
}
