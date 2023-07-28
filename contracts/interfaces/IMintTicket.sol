// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/interfaces/IIssuer.sol";

interface IMintTicket {
    struct TokenData {
        address issuer;
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

    function transferFrom(address from, address to, uint256 tokenId) external;

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * Add a new project to the tickets contract, so that the project mint
     * tickets can be suported.
     * @param gracingPeriod number of seconds during which the tickets of the 
     * project cannot be claimed publicly
     * @param metadata string metadata associated with the ticket, so that it
     * display properly in a wallet
     * 
     * TODO: We should use the Factory instanciation pattern to have 1 mint 
     * ticket contract per project, as opposed to a single contract holding
     * everything.
     */
    function createProject(uint256 gracingPeriod, string calldata metadata) external;

    /**
     * The issuer can instanciate a new ticket with an initial price (the mint
     * price is used as the initial price)
     * @param minter the recipient of the ticket
     * @param price initial price of the ticket
     */
    function mint(address minter, uint256 price) external;

    /**
     * Owners of tickets can update their public price (price at which anyone
     * can claim the ticket). By updating the price, they should provide the
     * necessary tax for covering the number of days they provided.
     * @param tokenId ID of the ticket
     * @param price new price
     * @param coverage number of days of tax coverage
     */
    function updatePrice(uint256 tokenId, uint256 price, uint256 coverage) external payable;

    /**
     * Anyone can pay the tax of a ticket, it will extend its coverage based on
     * its price. Refunds excess in case the tax payed is not a round multiplier
     * of the daily tax.
     * @param tokenId ID of the ticket
     */
    function payTax(uint256 tokenId) external payable;

    /**
     * Tickets can be claimed if:
     * - owners have failed to pay the tax (in which case the ticket enters an
     * automatic linear dutch auction over a day, to reach a resting price)
     * - the ticket is not in gracing period anymore (in which case the buyer
     * must provide the price requested by the owner)
     * @param tokenId ID of the ticket
     * @param price the new price at which the ticket will be set after claim
     * @param coverage number of days of coverage
     * @param transferTo (opt) address to which the ticket should be transfered
     * as a result of the claim
     */
    function claim(
        uint256 tokenId,
        uint256 price,
        uint256 coverage,
        address transferTo
    ) external payable;

    /**
     * Is called by the issuer to consume a ticket in exchange of an iteration,
     * during the execution of the mintWithTicket function.
     * @param owner owner of a ticket
     * @param tokenId ID of a ticket
     * @param issuer the address of the issuer for which the ticket should be 
     * exchanged
     * 
     * TODO: once we move to the factory pattern, the issuer will not be
     * required anymore.
     */
    function consume(address owner, uint256 tokenId, address issuer) external payable;
}
