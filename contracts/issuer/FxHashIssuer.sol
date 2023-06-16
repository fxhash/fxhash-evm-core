// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "contracts/interfaces/IFxHashIssuer.sol";
import "contracts/interfaces/IMintTicket.sol";

contract FxHashIssuer is IFxHashIssuer {
    IMintTicket ticket;

    constructor(address _ticket) {
        ticket = IMintTicket(_ticket);
    }

    function getUserActions(
        address addr
    ) external view override returns (UserActions memory) {}

    function getTokenPrimarySplit(
        uint256 projectId,
        uint256 amount
    ) external override returns (address receiver, uint256 royaltyAmount) {
        return (address(0), 1000);
    }

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
}
