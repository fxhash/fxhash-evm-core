// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Clones} from "openzeppelin/contracts/proxy/Clones.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";

import {IFxMintTicket721} from "src/interfaces/IFxMintTicket721.sol";
import {IFxTicketFactory} from "src/interfaces/IFxTicketFactory.sol";

/**
 * @title FxTicketFactory
 * @notice See the documentation in {IFxTicketFactory}
 */
contract FxTicketFactory is IFxTicketFactory, Ownable {
    /// @inheritdoc IFxTicketFactory
    address public implementation;
    /// @inheritdoc IFxTicketFactory
    uint48 public minGracePeriod;
    /// @inheritdoc IFxTicketFactory
    uint48 public ticketId;
    /// @inheritdoc IFxTicketFactory
    mapping(uint48 => address) public tickets;
    /// @inheritdoc IFxTicketFactory
    mapping(address => uint256) public nonces;

    /// @dev Initializes FxMintTicket721 implementation contract
    constructor(address _admin, address _implementation, uint48 _gracePeriod) {
        _setGracePeriod(_gracePeriod);
        _setImplementation(_implementation);
        _transferOwnership(_admin);
    }

    /// @inheritdoc IFxTicketFactory
    function createTicket(
        address _owner,
        address _genArt721,
        uint48 _gracePeriod,
        string calldata _baseURI
    ) external returns (address mintTicket) {
        if (_owner == address(0)) revert InvalidOwner();
        if (_genArt721 == address(0)) revert InvalidToken();
        if (_gracePeriod < minGracePeriod) revert InvalidGracePeriod();

        mintTicket = Clones.cloneDeterministic(implementation, bytes32(nonces[msg.sender]));
        nonces[msg.sender]++;
        tickets[++ticketId] = mintTicket;

        emit TicketCreated(ticketId, _owner, mintTicket);

        IFxMintTicket721(mintTicket).initialize(_owner, _genArt721, _gracePeriod, _baseURI);
    }

    /// @inheritdoc IFxTicketFactory
    function setImplementation(address _implementation) external onlyOwner {
        _setImplementation(_implementation);
    }

    /// @dev Sets the implementation address
    function _setImplementation(address _implementation) internal {
        implementation = _implementation;
        emit ImplementationUpdated(msg.sender, _implementation);
    }

    /// @inheritdoc IFxTicketFactory
    function setGracePeriod(uint48 _gracePeriod) external onlyOwner {
        _setGracePeriod(_gracePeriod);
    }

    /// @dev Sets the minimum grace period
    function _setGracePeriod(uint48 _gracePeriod) internal {
        minGracePeriod = _gracePeriod;
        emit GracePeriodUpdated(msg.sender, _gracePeriod);
    }
}
