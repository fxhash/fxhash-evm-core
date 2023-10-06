// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IRedeemer {
    error InvalidToken();
    error NotAuthorized();

    event Redeemed(address indexed ticket, uint256 indexed tokenId, address indexed owner, address token);

    function redeem(address _ticket, uint256 _tokenId) external;
}
