// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IFxTicketFactory {
    event ImplementationUpdated(address indexed _owner, address indexed _implementation);

    event TicketCreated(
        uint96 indexed _ticketId, address indexed _owner, address indexed _mintTicket
    );

    error InvalidGracePeriod();
    error InvalidOwner();
    error InvalidToken();

    function createTicket(address _owner, address _genArt721, uint48 _gracePeriod)
        external
        returns (address);

    function setImplementation(address _implementation) external;

    function implementation() external view returns (address);

    function ticketId() external view returns (uint96);

    function tickets(uint96) external view returns (address);
}
