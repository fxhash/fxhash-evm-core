// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "contracts/interfaces/IMintTicket.sol";
import "contracts/libs/LibUserActions.sol";
import "contracts/interfaces/IIssuer.sol";

contract MockIssuer is IIssuer {
    IMintTicket ticket;

    constructor(address _ticket) {
        ticket = IMintTicket(_ticket);
    }

    function getUserActions(
        address addr
    ) external view returns (LibUserActions.UserAction memory) {}

    //TODO: remove this placeholder (used for tests)
    function consume(
        address owner,
        uint256 tokenId,
        uint256 projectId
    ) external payable {
        ticket.consume(owner, tokenId, projectId);
    }

    //TODO: remove this placeholder (used for tests)
    function mint(uint256 projectId, address minter, uint256 price) external {
        ticket.mint(projectId, minter, price);
    }

    //TODO: remove this placeholder (used for tests)
    function createProject(
        uint256 projectId,
        uint256 gracingPeriod,
        string calldata metadata
    ) external {
        ticket.createProject(projectId, gracingPeriod, metadata);
    }

    function getIssuer(
        uint256 issuerId
    ) external view override returns (LibIssuer.IssuerData memory) {}

    function mintIssuer(MintIssuerInput calldata params) external override {}

    function mint(MintInput calldata params) external payable override {}

    function mintWithTicket(
        MintWithTicketInput calldata params
    ) external override {}

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    )
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {}

    function primarySplitInfo(
        uint256 tokenId,
        uint256 salePrice
    )
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {}

    function setCodex(uint256 issuerId, uint256 codexId) external override {}

    function supportsInterface(
        bytes4 interfaceId
    ) external view override returns (bool) {}
}
