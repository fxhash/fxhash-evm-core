// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMintTicket {
    struct TokenData {
        uint256 projectId;
        address minter;
        uint256 createdAt;
        uint256 taxationLocked;
        uint256 taxationStart;
        uint256 price;
    }
    struct ProjectData {
        uint256 gracingPeriod; //in days
        string metadata;
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function tokensOf(address owner) external view returns (uint256[] memory);

    function balanceOf(address owner) external view returns (uint256);

    function transferFrom(address from, address to, uint256 tokenId) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function createProject(
        uint256 projectId,
        uint256 gracingPeriod,
        string calldata metadata
    ) external;

    function mint(uint256 projectId, address minter, uint256 price) external;

    function updatePrice(
        uint256 tokenId,
        uint256 price,
        uint256 coverage
    ) external payable;

    function payTax(uint256 tokenId) external payable;

    function claim(
        uint256 tokenId,
        uint256 price,
        uint256 coverage,
        address transferTo
    ) external payable;

    function consume(
        address owner,
        uint256 tokenId,
        uint256 projectId
    ) external payable;
}
