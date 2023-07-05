// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibUserActions.sol";

interface IUserActions {
    function getUserActions(
        address addr
    ) external view returns (LibUserActions.UserAction memory);

    function setLastIssuerMinted(address addr, address issuer) external;

    function setLastMinted(
        address addr,
        address tokenContract,
        uint256 tokenId
    ) external;

    function resetLastIssuerMinted(address addr, address issuer) external;
}
