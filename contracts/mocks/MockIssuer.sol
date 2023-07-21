// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "contracts/interfaces/IMintTicket.sol";
import "contracts/interfaces/IGenTk.sol";

contract MockIssuer {
    IMintTicket ticket;
    IGenTk gentk;
    LibIssuer.IssuerData private issuer;

    constructor() {}

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
        ticket.mintTicket(minter, price);
    }

    function mint(IGenTk.TokenParams calldata _params) external {
        gentk.mint(_params);
    }

    //TODO: remove this placeholder (used for tests)
    function createTicket(uint256 gracingPeriod) external {
        ticket.createTicket(gracingPeriod);
    }

    function getIssuer() external view returns (LibIssuer.IssuerData memory) {
        return issuer;
    }

    function setTicket(address _ticket) external {
        ticket = IMintTicket(_ticket);
    }

    function setGenTk(address _gtk) external {
        gentk = IGenTk(_gtk);
    }
}
