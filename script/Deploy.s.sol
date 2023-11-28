// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Script.sol";
import "script/utils/Constants.sol";
import "src/utils/Constants.sol";
import "test/utils/Constants.sol";

import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";
import {FxGenArt721} from "src/tokens/FxGenArt721.sol";
import {FxIssuerFactory} from "src/factories/FxIssuerFactory.sol";
import {FxMintTicket721} from "src/tokens/FxMintTicket721.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";
import {FxTicketFactory} from "src/factories/FxTicketFactory.sol";

import {DutchAuction} from "src/minters/DutchAuction.sol";
import {FixedPrice} from "src/minters/FixedPrice.sol";
import {IPFSRenderer} from "src/renderers/IPFSRenderer.sol";
import {PseudoRandomizer} from "src/randomizers/PseudoRandomizer.sol";
import {TicketRedeemer} from "src/minters/TicketRedeemer.sol";

import {ConfigInfo} from "src/interfaces/IFxContractRegistry.sol";
import {LibClone} from "solady/src/utils/LibClone.sol";

contract Deploy is Script {
    // Core
    FxContractRegistry internal fxContractRegistry;
    FxGenArt721 internal fxGenArt721;
    FxIssuerFactory internal fxIssuerFactory;
    FxMintTicket721 internal fxMintTicket721;
    FxRoleRegistry internal fxRoleRegistry;
    FxTicketFactory internal fxTicketFactory;

    // Periphery
    DutchAuction internal dutchAuction;
    FixedPrice internal fixedPrice;
    IPFSRenderer internal ipfsRenderer;
    PseudoRandomizer internal pseudoRandomizer;
    TicketRedeemer internal ticketRedeemer;

    // Accounts
    address internal admin;
    address internal creator;

    // State
    address[] internal contracts;
    string[] internal names;
    ConfigInfo internal configInfo;

    /*//////////////////////////////////////////////////////////////////////////
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    modifier onlyLocalForge() {
        try vm.activeFork() returns (uint256) {
            return;
        } catch {
            _;
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        _createAccounts();
        _configureInfo(
            admin,
            SECONDARY_FEE_ALLOCATION,
            PRIMARY_FEE_ALLOCATION,
            LOCK_TIME,
            REFERRER_SHARE,
            DEFAULT_METADATA_URI
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      RUN
    //////////////////////////////////////////////////////////////////////////*/
    function run() public virtual {
        _mockSplits();
        vm.startBroadcast();
        _deployContracts();
        _registerContracts();
        _grantRoles();
        vm.stopBroadcast();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ACCOUNTS
    //////////////////////////////////////////////////////////////////////////*/

    function _createAccounts() internal virtual {
        admin = msg.sender;
        creator = makeAddr("creator");

        vm.label(admin, "Admin");
        vm.label(creator, "Creator");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                CONFIGURATIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _configureInfo(
        address _feeReceiver,
        uint32 _secondaryFeeAllocation,
        uint32 _primaryFeeAllocation,
        uint32 _lockTime,
        uint64 _referrerShare,
        string memory _defaultMetadataURI
    ) internal virtual {
        configInfo.feeReceiver = _feeReceiver;
        configInfo.secondaryAllocation = _secondaryFeeAllocation;
        configInfo.primaryAllocation = _primaryFeeAllocation;
        configInfo.lockTime = _lockTime;
        configInfo.referrerShare = _referrerShare;
        configInfo.defaultMetadataURI = _defaultMetadataURI;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    DEPLOYMENTS
    //////////////////////////////////////////////////////////////////////////*/

    function _deployContracts() internal virtual {
        bytes32 salt = keccak256(abi.encode(vm.getNonce(admin)));

        // FxContractRegistry
        bytes memory creationCode = type(FxContractRegistry).creationCode;
        bytes memory constructorArgs = abi.encode(admin, configInfo);
        // init: cast keccak256(creationCode, abi.encode(constructorArgs))
        // salt: cast create2 --starts-with 00000000 --case-sensitive --deployer CREATE2_FACTORY --init-code-hash init
        fxContractRegistry = FxContractRegistry(_deployCreate2(creationCode, constructorArgs, salt));

        // FxRoleRegistry
        creationCode = type(FxRoleRegistry).creationCode;
        constructorArgs = abi.encode(admin);
        // init: cast keccak256(creationCode, abi.encode(constructorArgs))
        // salt: cast create2 --starts-with 00000000 --case-sensitive --deployer CREATE2_FACTORY --init-code-hash init
        fxRoleRegistry = FxRoleRegistry(_deployCreate2(creationCode, constructorArgs, salt));

        // FxGenArt721
        creationCode = type(FxGenArt721).creationCode;
        constructorArgs = abi.encode(fxContractRegistry, fxRoleRegistry);
        // init: cast keccak256(creationCode, abi.encode(constructorArgs))
        // salt: cast create2 --starts-with 00000000 --case-sensitive --deployer CREATE2_FACTORY --init-code-hash init
        fxGenArt721 = FxGenArt721(_deployCreate2(creationCode, constructorArgs, salt));

        // FxIssuerFactory
        creationCode = type(FxIssuerFactory).creationCode;
        constructorArgs = abi.encode(admin, fxRoleRegistry, fxGenArt721);
        fxIssuerFactory = FxIssuerFactory(_deployCreate2(creationCode, constructorArgs, salt));

        // FxMintTicket721
        creationCode = type(FxMintTicket721).creationCode;
        constructorArgs = abi.encode(fxContractRegistry, fxRoleRegistry);
        // init: cast keccak256(creationCode, abi.encode(constructorArgs))
        // salt: cast create2 --starts-with 00000000 --case-sensitive --deployer CREATE2_FACTORY --init-code-hash init
        fxMintTicket721 = FxMintTicket721(_deployCreate2(creationCode, constructorArgs, salt));

        // FxTicketFactory
        creationCode = type(FxTicketFactory).creationCode;
        constructorArgs = abi.encode(admin, fxMintTicket721, ONE_DAY);
        fxTicketFactory = FxTicketFactory(_deployCreate2(creationCode, constructorArgs, salt));

        vm.label(address(fxContractRegistry), "FxContractRegistry");
        vm.label(address(fxGenArt721), "FxGenArt721");
        vm.label(address(fxIssuerFactory), "FxIssuerFactory");
        vm.label(address(fxMintTicket721), "FxMintTicket721");
        vm.label(address(fxRoleRegistry), "FxRoleRegistry");
        vm.label(address(fxTicketFactory), "FxTicketFactory");

        // PseudoRandomizer
        creationCode = type(PseudoRandomizer).creationCode;
        pseudoRandomizer = PseudoRandomizer(_deployCreate2(creationCode, salt));

        // IPFSRenderer
        creationCode = type(IPFSRenderer).creationCode;
        constructorArgs = abi.encode(fxContractRegistry);
        ipfsRenderer = IPFSRenderer(_deployCreate2(creationCode, constructorArgs, salt));

        // DutchAuction
        creationCode = type(DutchAuction).creationCode;
        dutchAuction = DutchAuction(_deployCreate2(creationCode, salt));

        // FixedPrice
        creationCode = type(FixedPrice).creationCode;
        fixedPrice = FixedPrice(_deployCreate2(creationCode, salt));

        // TicketRedeemer
        creationCode = type(TicketRedeemer).creationCode;
        ticketRedeemer = TicketRedeemer(_deployCreate2(creationCode, salt));

        vm.label(address(dutchAuction), "DutchAuction");
        vm.label(address(fixedPrice), "FixedPrice");
        vm.label(address(ipfsRenderer), "IPFSRenderer");
        vm.label(address(pseudoRandomizer), "PseudoRandomizer");
        vm.label(address(ticketRedeemer), "TicketRedeemer");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SETTERS
    //////////////////////////////////////////////////////////////////////////*/

    function _grantRoles() internal virtual {
        fxRoleRegistry.grantRole(CREATOR_ROLE, creator);
        fxRoleRegistry.grantRole(MINTER_ROLE, address(dutchAuction));
        fxRoleRegistry.grantRole(MINTER_ROLE, address(fixedPrice));
        fxRoleRegistry.grantRole(MINTER_ROLE, address(ticketRedeemer));
    }

    function _registerContracts() internal virtual {
        names.push(FX_CONTRACT_REGISTRY);
        names.push(FX_GEN_ART_721);
        names.push(FX_ISSUER_FACTORY);
        names.push(FX_MINT_TICKET_721);
        names.push(FX_ROLE_REGISTRY);
        names.push(FX_TICKET_FACTORY);

        names.push(DUTCH_AUCTION);
        names.push(FIXED_PRICE);
        names.push(IPFS_RENDERER);
        names.push(PSEUDO_RANDOMIZER);
        names.push(TICKET_REDEEMER);

        contracts.push(address(fxContractRegistry));
        contracts.push(address(fxGenArt721));
        contracts.push(address(fxIssuerFactory));
        contracts.push(address(fxMintTicket721));
        contracts.push(address(fxRoleRegistry));
        contracts.push(address(fxTicketFactory));

        contracts.push(address(dutchAuction));
        contracts.push(address(fixedPrice));
        contracts.push(address(ipfsRenderer));
        contracts.push(address(pseudoRandomizer));
        contracts.push(address(ticketRedeemer));

        fxContractRegistry.register(names, contracts);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CREATE2
    //////////////////////////////////////////////////////////////////////////*/

    function _deployCreate2(bytes memory _creationCode, bytes32 _salt) internal returns (address deployedAddr) {
        deployedAddr = _deployCreate2(_creationCode, bytes(""), _salt);
    }

    function _deployCreate2(
        bytes memory _creationCode,
        bytes memory _constructorArgs,
        bytes32 _salt
    ) internal returns (address deployedAddr) {
        (bool success, bytes memory response) = CREATE2_FACTORY.call(
            bytes.concat(_salt, _creationCode, _constructorArgs)
        );
        deployedAddr = address(bytes20(response));
        require(success, "deployment failed");
    }

    function _mockSplits() internal onlyLocalForge {
        bytes memory splitMainBytecode = abi.encodePacked(SPLITS_MAIN_CREATION_CODE, abi.encode());
        address deployedAddr;
        vm.setNonce(SPLITS_DEPLOYER, 0);
        vm.prank(SPLITS_DEPLOYER);
        assembly {
            deployedAddr := create(0, add(splitMainBytecode, 32), mload(splitMainBytecode))
        }
    }

    function _computeTicketAddr(address _deployer) internal view returns (address) {
        uint256 nonce = fxTicketFactory.nonces(_deployer);
        bytes32 salt = keccak256(abi.encode(_deployer, nonce));
        return LibClone.predictDeterministicAddress(address(fxMintTicket721), salt, address(fxTicketFactory));
    }

    function _computeCreate2Addr(
        bytes memory _creationCode,
        bytes memory _constructorArgs,
        bytes32 _salt
    ) internal pure {
        computeCreate2Address(_salt, hashInitCode(_creationCode, _constructorArgs));
    }

    function _initCode(bytes memory _creationCode, bytes memory _constructorArgs) internal pure returns (bytes memory) {
        return bytes.concat(_creationCode, _constructorArgs);
    }
}
