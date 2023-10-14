// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Clones} from "openzeppelin/contracts/proxy/Clones.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";

import {IFxMintTicket721, MintInfo} from "src/interfaces/IFxMintTicket721.sol";
import {IFxTicketFactory} from "src/interfaces/IFxTicketFactory.sol";

/**
 * @title FxTicketFactory
 * @author fxhash
 * @dev See the documentation in {IFxTicketFactory}
 */
contract FxTicketFactory is IFxTicketFactory, Ownable {
    /**
     * @inheritdoc IFxTicketFactory
     */
    address public implementation;

    /**
     * @inheritdoc IFxTicketFactory
     */
    uint48 public minGracePeriod;

    /**
     * @inheritdoc IFxTicketFactory
     */
    uint48 public ticketId;

    /**
     * @inheritdoc IFxTicketFactory
     */
    mapping(address => uint256) public nonces;

    /**
     * @inheritdoc IFxTicketFactory
     */
    mapping(uint48 => address) public tickets;

    /**
     * @dev Initializes factory owner, FxMintTicket721 implementation and minimum grace period
     */
    constructor(address _admin, address _implementation, uint48 _gracePeriod) {
        _transferOwnership(_admin);
        _setImplementation(_implementation);
        _setGracePeriod(_gracePeriod);
    }

    /**
     * @inheritdoc IFxTicketFactory
     */
    function createTicket(
        address _owner,
        address _genArt721,
        address _redeemer,
        uint48 _gracePeriod,
        string calldata _baseURI,
        MintInfo[] calldata _mintInfo
    ) external returns (address mintTicket) {
        if (_owner == address(0)) revert InvalidOwner();
        if (_genArt721 == address(0)) revert InvalidToken();
        if (_redeemer == address(0)) revert InvalidRedeemer();
        if (_gracePeriod < minGracePeriod) revert InvalidGracePeriod();

        bytes32 salt = keccak256(abi.encode(msg.sender, nonces[msg.sender]));
        mintTicket = Clones.cloneDeterministic(implementation, salt);
        nonces[msg.sender]++;
        tickets[++ticketId] = mintTicket;

        emit TicketCreated(ticketId, mintTicket, _owner);

        IFxMintTicket721(mintTicket).initialize(_owner, _genArt721, _redeemer, _gracePeriod, _baseURI, _mintInfo);
    }

    /**
     * @inheritdoc IFxTicketFactory
     */
    function setGracePeriod(uint48 _gracePeriod) external onlyOwner {
        _setGracePeriod(_gracePeriod);
    }

    /**
     * @inheritdoc IFxTicketFactory
     */
    function setImplementation(address _implementation) external onlyOwner {
        _setImplementation(_implementation);
    }

    /**
     * @dev Sets the minimum grace period before a token enters harberger taxation
     */
    function _setGracePeriod(uint48 _gracePeriod) internal {
        minGracePeriod = _gracePeriod;
        emit GracePeriodUpdated(msg.sender, _gracePeriod);
    }

    /**
     * @dev Sets the FxMintTicket721 implementation contract
     */
    function _setImplementation(address _implementation) internal {
        implementation = _implementation;
        emit ImplementationUpdated(msg.sender, _implementation);
    }
}
