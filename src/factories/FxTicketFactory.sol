// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibClone} from "solady/src/utils/LibClone.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";

import {IFxMintTicket721, MintInfo} from "src/interfaces/IFxMintTicket721.sol";
import {IFxTicketFactory} from "src/interfaces/IFxTicketFactory.sol";

import {ONE_DAY} from "src/utils/Constants.sol";

/**
 * @title FxTicketFactory
 * @author fx(hash)
 * @dev See the documentation in {IFxTicketFactory}
 */
contract FxTicketFactory is IFxTicketFactory, Ownable {
    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

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

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Initializes factory owner, FxMintTicket721 implementation and minimum grace period
     */
    constructor(address _admin, address _implementation, uint48 _gracePeriod) {
        _initializeOwner(_admin);
        _setImplementation(_implementation);
        _setMinGracePeriod(_gracePeriod);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxTicketFactory
     */
    function createTicket(bytes calldata _creationInfo) external returns (address mintTicket) {
        (
            address _owner,
            address _genArt721,
            address _redeemer,
            address _renderer,
            uint48 _gracePeriod,
            MintInfo[] memory _mintInfo
        ) = abi.decode(_creationInfo, (address, address, address, address, uint48, MintInfo[]));

        mintTicket = createTicket(_owner, _genArt721, _redeemer, _renderer, _gracePeriod, _mintInfo);
    }

    /**
     * @inheritdoc IFxTicketFactory
     */
    function setImplementation(address _implementation) external onlyOwner {
        _setImplementation(_implementation);
    }

    /**
     * @inheritdoc IFxTicketFactory
     */
    function setMinGracePeriod(uint48 _gracePeriod) external onlyOwner {
        _setMinGracePeriod(_gracePeriod);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxTicketFactory
     */
    function createTicket(
        address _owner,
        address _genArt721,
        address _redeemer,
        address _renderer,
        uint48 _gracePeriod,
        MintInfo[] memory _mintInfo
    ) public returns (address mintTicket) {
        if (_owner == address(0)) revert InvalidOwner();
        if (_genArt721 == address(0)) revert InvalidToken();
        if (_redeemer == address(0)) revert InvalidRedeemer();
        if (_renderer == address(0)) revert InvalidRenderer();
        if (_gracePeriod < minGracePeriod) revert InvalidGracePeriod();

        bytes32 salt = keccak256(abi.encode(msg.sender, nonces[msg.sender]));
        mintTicket = LibClone.cloneDeterministic(implementation, salt);
        nonces[msg.sender]++;
        tickets[++ticketId] = mintTicket;

        emit TicketCreated(ticketId, mintTicket, _owner);

        IFxMintTicket721(mintTicket).initialize(_owner, _genArt721, _redeemer, _renderer, _gracePeriod, _mintInfo);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxTicketFactory
     */
    function getTicketAddress(address _sender) external view returns (address) {
        bytes32 salt = keccak256(abi.encode(_sender, nonces[_sender]));
        return LibClone.predictDeterministicAddress(implementation, salt, address(this));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Sets the FxMintTicket721 implementation contract
     */
    function _setImplementation(address _implementation) internal {
        implementation = _implementation;
        emit ImplementationUpdated(msg.sender, _implementation);
    }

    /**
     * @dev Sets the minimum grace period of time for when token enters harberger taxation
     */
    function _setMinGracePeriod(uint48 _gracePeriod) internal {
        // if (_gracePeriod < ONE_DAY) revert InvalidGracePeriod();
        minGracePeriod = _gracePeriod;
        emit GracePeriodUpdated(msg.sender, _gracePeriod);
    }
}
