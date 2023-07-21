// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/interfaces/IIssuer.sol";

interface IMintTicket {
    struct TicketData {
        address issuer;
        address owner;
        uint256 createdAt;
        uint256 taxationLocked;
        uint256 taxationStart;
        uint256 price;
    }

    function createTicket(uint256 _gracingPeriod) external;

    function mintTicket(address _minter, uint256 _price) external;

    function updatePrice(uint256 _tokenId, uint256 _price, uint256 _coverage) external payable;

    function payTax(uint256 _tokenId) external payable;

    function claim(
        uint256 _tokenId,
        uint256 _price,
        uint256 _coverage,
        address _transferTo
    ) external payable;

    function consume(address _owner, uint256 _tokenId, address _issuer) external payable;
}
