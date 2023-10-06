// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Clones} from "openzeppelin/contracts/proxy/Clones.sol";
import {IFxMintTicket721} from "src/interfaces/IFxMintTicket721.sol";
import {IFxTicketFactory} from "src/interfaces/IFxTicketFactory.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";

import {ONE_DAY} from "src/utils/Constants.sol";

/**
 * @title FxTicketFactory
 * @notice See the documentation in {IFxTicketFactory}
 */
contract FxTicketFactory is IFxTicketFactory, Ownable {
    /// @inheritdoc IFxTicketFactory
    uint96 public ticketId;
    /// @inheritdoc IFxTicketFactory
    address public implementation;
    /// @inheritdoc IFxTicketFactory
    mapping(uint96 => address) public tickets;
    /// @inheritdoc IFxTicketFactory
    mapping(address => uint256) public deployerNonces;

    /// @dev Initializes FxMintTicket721 implementation contract
    constructor(address _implementation) {
        _setImplementation(_implementation);
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
        if (_gracePeriod < ONE_DAY) revert InvalidGracePeriod();

        uint256 nonce = deployerNonces[msg.sender];
        mintTicket = Clones.cloneDeterministic(implementation, bytes32(nonce));
        deployerNonces[msg.sender]++;

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
}
