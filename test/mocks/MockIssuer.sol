// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IGenTk, TokenParams} from "contracts/interfaces/IGenTk.sol";
import {IMintTicket} from "contracts/interfaces/IMintTicket.sol";
import {IssuerData} from "contracts/interfaces/IIssuer.sol";

contract MockIssuer {
    IMintTicket ticket;
    IGenTk gentk;
    IssuerData private issuer;

    constructor() {}

    function getTokenPrimarySplit(
        uint256 /* projectId */,
        uint256 /* amount */
    ) external pure returns (address receiver, uint256 royaltyAmount) {
        return (address(0), 1000);
    }

    //TODO: remove this placeholder (used for tests)
    function consume(address owner, uint256 tokenId, address _issuer) external payable {
        ticket.consume(owner, tokenId, _issuer);
    }

    //TODO: remove this placeholder (used for tests)
    function mintTicket(address minter, uint256 price) external {
        ticket.mint(minter, price);
    }

    function mint(TokenParams calldata _params) external {
        gentk.mint(_params);
    }

    //TODO: remove this placeholder (used for tests)
    function createProject(uint256 gracingPeriod, string calldata metadata) external {
        ticket.createProject(gracingPeriod, metadata);
    }

    function getIssuer() external view returns (IssuerData memory) {
        return issuer;
    }

    function setTicket(address _ticket) external {
        ticket = IMintTicket(_ticket);
    }

    function setGenTk(address _gtk) external {
        gentk = IGenTk(_gtk);
    }
}
