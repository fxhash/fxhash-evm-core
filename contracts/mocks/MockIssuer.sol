// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "contracts/interfaces/IMintTicket.sol";
import "contracts/libs/LibUserActions.sol";

contract MockIssuer {
    IMintTicket ticket;

    constructor(address _ticket) {
        ticket = IMintTicket(_ticket);
    }

    function getUserActions(address addr)
        external
        view
        returns (LibUserActions.UserAction memory)
    {}

    function getTokenPrimarySplit(uint256 projectId, uint256 amount)
        external
        pure
        returns (address receiver, uint256 royaltyAmount)
    {
        return (address(0), 1000);
    }

    //TODO: remove this placeholder (used for tests)
    function consume(
        address owner,
        uint256 tokenId,
        address issuer
    ) external payable {
        ticket.consume(owner, tokenId, issuer);
    }

    //TODO: remove this placeholder (used for tests)
    function mint(address minter, uint256 price) external {
        ticket.mint(minter, price);
    }

    //TODO: remove this placeholder (used for tests)
    function createProject(uint256 gracingPeriod, string calldata metadata)
        external
    {
        ticket.createProject(gracingPeriod, metadata);
    }
}
