// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "contracts/interfaces/IMintTicket.sol";
import "contracts/interfaces/IGenTk.sol";

contract MockIssuer {
    IMintTicket ticket;
    IGenTk gentk;
    LibIssuer.IssuerData private issuer;

    constructor(address _ticket) {
        ticket = IMintTicket(_ticket);
    }

    function getTokenPrimarySplit(
        uint256 projectId,
        uint256 amount
    ) external pure returns (address receiver, uint256 royaltyAmount) {
        return (address(0), 1000);
    }

    //TODO: remove this placeholder (used for tests)
    function consume(address owner, uint256 tokenId, address issuer) external payable {
        ticket.consume(owner, tokenId, issuer);
    }

    //TODO: remove this placeholder (used for tests)
    function mintTicket(address minter, uint256 price) external {
        ticket.mint(minter, price);
    }

    function mint(IGenTk.TokenParams calldata _params) external {
        gentk.mint(_params);
    }

    //TODO: remove this placeholder (used for tests)
    function createProject(uint256 gracingPeriod, string calldata metadata) external {
        ticket.createProject(gracingPeriod, metadata);
    }

    function getIssuer() external view returns (LibIssuer.IssuerData memory) {
        return issuer;
    }
}
