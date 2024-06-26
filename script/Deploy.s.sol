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
import {FarcasterFrame} from "src/minters/FarcasterFrame.sol";
import {FeeManager} from "src/minters/extensions/FeeManager.sol";
import {FixedPrice} from "src/minters/FixedPrice.sol";
import {FixedPriceParams} from "src/minters/FixedPriceParams.sol";
import {IPFSRenderer} from "src/renderers/IPFSRenderer.sol";
import {ONCHFSRenderer} from "src/renderers/ONCHFSRenderer.sol";
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
    FarcasterFrame internal farcasterFrame;
    FeeManager internal feeManager;
    FixedPrice internal fixedPrice;
    FixedPriceParams internal fixedPriceParams;
    IPFSRenderer internal ipfsRenderer;
    ONCHFSRenderer internal onchfsRenderer;
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
            // FEE_RECEIVER,
            PRIMARY_FEE_ALLOCATION,
            SECONDARY_FEE_ALLOCATION,
            LOCK_TIME,
            REFERRER_SHARE,
            DEFAULT_METADATA_URI,
            EXTERNAL_URI
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
        uint32 _primaryFeeAllocation,
        uint32 _secondaryFeeAllocation,
        uint32 _lockTime,
        uint64 _referrerShare,
        string memory _defaultMetadataURI,
        string memory _externalURI
    ) internal virtual {
        configInfo.feeReceiver = _feeReceiver;
        configInfo.primaryFeeAllocation = _primaryFeeAllocation;
        configInfo.secondaryFeeAllocation = _secondaryFeeAllocation;
        configInfo.lockTime = _lockTime;
        configInfo.referrerShare = _referrerShare;
        configInfo.defaultMetadataURI = _defaultMetadataURI;
        configInfo.externalURI = _externalURI;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    DEPLOYMENTS
    //////////////////////////////////////////////////////////////////////////*/

    function _deployContracts() internal virtual {
        bytes32 salt = keccak256(abi.encode(vm.getNonce(admin)));

        // FxContractRegistry
        bytes memory creationCode = type(FxContractRegistry).creationCode;
        bytes memory constructorArgs = abi.encode(admin, configInfo);
        fxContractRegistry = FxContractRegistry(_deployCreate2(creationCode, constructorArgs, salt));

        // FxRoleRegistry
        creationCode = type(FxRoleRegistry).creationCode;
        constructorArgs = abi.encode(admin);
        fxRoleRegistry = FxRoleRegistry(_deployCreate2(creationCode, constructorArgs, salt));

        // FxGenArt721
        creationCode = type(FxGenArt721).creationCode;
        constructorArgs = abi.encode(fxContractRegistry, fxRoleRegistry);
        fxGenArt721 = FxGenArt721(_deployCreate2(creationCode, constructorArgs, salt));

        // FxIssuerFactory
        creationCode = type(FxIssuerFactory).creationCode;
        constructorArgs = abi.encode(admin, fxRoleRegistry, fxGenArt721);
        fxIssuerFactory = FxIssuerFactory(_deployCreate2(creationCode, constructorArgs, salt));

        // FxMintTicket721
        creationCode = type(FxMintTicket721).creationCode;
        constructorArgs = abi.encode(fxContractRegistry, fxRoleRegistry);
        fxMintTicket721 = FxMintTicket721(_deployCreate2(creationCode, constructorArgs, salt));

        // FxTicketFactory
        creationCode = type(FxTicketFactory).creationCode;
        constructorArgs = abi.encode(admin, fxMintTicket721, ((block.chainid == MAINNET) ? ONE_DAY : FIVE_MINUTES));
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

        // ONCHFSRenderer
        creationCode = type(ONCHFSRenderer).creationCode;
        constructorArgs = abi.encode(fxContractRegistry);
        onchfsRenderer = ONCHFSRenderer(_deployCreate2(creationCode, constructorArgs, salt));

        // FeeManager
        creationCode = type(FeeManager).creationCode;
        constructorArgs = abi.encode(admin, MINT_FEE);
        feeManager = FeeManager(payable(_deployCreate2(creationCode, constructorArgs, salt)));

        // DutchAuction
        creationCode = type(DutchAuction).creationCode;
        constructorArgs = abi.encode(admin, feeManager);
        dutchAuction = DutchAuction(_deployCreate2(creationCode, constructorArgs, salt));

        // FixedPrice
        creationCode = type(FixedPrice).creationCode;
        constructorArgs = abi.encode(admin, FRAME_CONTROLLER, feeManager);
        fixedPrice = FixedPrice(_deployCreate2(creationCode, constructorArgs, salt));

        // FixedPriceParams
        creationCode = type(FixedPriceParams).creationCode;
        constructorArgs = abi.encode(admin);
        fixedPriceParams = FixedPriceParams(_deployCreate2(creationCode, constructorArgs, salt));

        // FixedPriceFrame
        creationCode = type(FarcasterFrame).creationCode;
        constructorArgs = abi.encode(admin, FRAME_CONTROLLER);
        farcasterFrame = FarcasterFrame(_deployCreate2(creationCode, constructorArgs, salt));

        // TicketRedeemer
        creationCode = type(TicketRedeemer).creationCode;
        constructorArgs = abi.encode(admin);
        ticketRedeemer = TicketRedeemer(_deployCreate2(creationCode, constructorArgs, salt));

        vm.label(address(dutchAuction), "DutchAuction");
        vm.label(address(feeManager), "FeeManager");
        vm.label(address(fixedPrice), "FixedPrice");
        vm.label(address(fixedPrice), "FixedPriceParams");
        vm.label(address(ipfsRenderer), "IPFSRenderer");
        vm.label(address(onchfsRenderer), "ONCHFSRenderer");
        vm.label(address(farcasterFrame), "FarcasterFrame");
        vm.label(address(pseudoRandomizer), "PseudoRandomizer");
        vm.label(address(ticketRedeemer), "TicketRedeemer");

        console.log('project_factory_v1: "%s",', address(fxIssuerFactory));
        console.log('mint_ticket_factory_v1: "%s",', address(fxTicketFactory));
        console.log('dutch_auction_minter_v1: "%s",', address(dutchAuction));
        console.log('fixed_price_minter_v1: "%s",', address(fixedPrice));
        console.log('fixed_price_params_minter_v1: "%s",', address(fixedPriceParams));
        console.log('ticket_redeemer_v1: "%s",', address(ticketRedeemer));
        console.log('ipfs_renderer_v1: "%s",', address(ipfsRenderer));
        console.log('onchfs_renderer_v1: "%s",', address(onchfsRenderer));
        console.log('randomizer_v1: "%s",', address(pseudoRandomizer));
        console.log('role_registry_v1: "%s",', address(fxRoleRegistry));
        console.log('contract_registry_v1: "%s",', address(fxContractRegistry));
        console.log('gen_art_token_impl_v1: "%s",', address(fxGenArt721));
        console.log('mint_ticket_impl_v1: "%s",', address(fxMintTicket721));
        console.log('farcaster_frame_minter_v1: "%s"', address(farcasterFrame));
        console.log('fee_manager_v1: "%s",', address(feeManager));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SETTERS
    //////////////////////////////////////////////////////////////////////////*/

    function _grantRoles() internal virtual {
        fxRoleRegistry.grantRole(CREATOR_ROLE, creator);
        fxRoleRegistry.grantRole(MINTER_ROLE, address(dutchAuction));
        fxRoleRegistry.grantRole(MINTER_ROLE, address(fixedPrice));
        fxRoleRegistry.grantRole(MINTER_ROLE, address(ticketRedeemer));
        fxRoleRegistry.grantRole(MINTER_ROLE, address(farcasterFrame));

        fxRoleRegistry.grantRole(ADMIN_ROLE, admin);
        fxRoleRegistry.grantRole(CREATOR_ROLE, admin);
        fxRoleRegistry.grantRole(MODERATOR_ROLE, admin);
        fxRoleRegistry.grantRole(SIGNER_ROLE, admin);

        fxRoleRegistry.grantRole(ADMIN_ROLE, FLORIAN);
        fxRoleRegistry.grantRole(CREATOR_ROLE, FLORIAN);
        fxRoleRegistry.grantRole(MODERATOR_ROLE, FLORIAN);
        fxRoleRegistry.grantRole(SIGNER_ROLE, FLORIAN);

        fxRoleRegistry.grantRole(ADMIN_ROLE, STEVEN);
        fxRoleRegistry.grantRole(CREATOR_ROLE, STEVEN);
        fxRoleRegistry.grantRole(MODERATOR_ROLE, STEVEN);
        fxRoleRegistry.grantRole(SIGNER_ROLE, STEVEN);

        fxRoleRegistry.grantRole(CREATOR_ROLE, IZZA);
        fxRoleRegistry.grantRole(CREATOR_ROLE, LEO);
        fxRoleRegistry.grantRole(CREATOR_ROLE, LOUIE);
        fxRoleRegistry.grantRole(CREATOR_ROLE, MARKUS);
    }

    function _registerContracts() internal virtual {
        names.push(FX_CONTRACT_REGISTRY);
        names.push(FX_GEN_ART_721);
        names.push(FX_ISSUER_FACTORY);
        names.push(FX_MINT_TICKET_721);
        names.push(FX_ROLE_REGISTRY);
        names.push(FX_TICKET_FACTORY);

        names.push(DUTCH_AUCTION);
        names.push(FARCASTER_FRAME);
        names.push(FEE_MANAGER);
        names.push(FIXED_PRICE);
        names.push(FIXED_PRICE_PARAMS);
        names.push(IPFS_RENDERER);
        names.push(ONCHFS_RENDERER);
        names.push(PSEUDO_RANDOMIZER);
        names.push(TICKET_REDEEMER);

        contracts.push(address(fxContractRegistry));
        contracts.push(address(fxGenArt721));
        contracts.push(address(fxIssuerFactory));
        contracts.push(address(fxMintTicket721));
        contracts.push(address(fxRoleRegistry));
        contracts.push(address(fxTicketFactory));

        contracts.push(address(dutchAuction));
        contracts.push(address(farcasterFrame));
        contracts.push(address(feeManager));
        contracts.push(address(fixedPrice));
        contracts.push(address(fixedPriceParams));
        contracts.push(address(ipfsRenderer));
        contracts.push(address(onchfsRenderer));
        contracts.push(address(pseudoRandomizer));
        contracts.push(address(ticketRedeemer));

        fxContractRegistry.register(names, contracts);
        fxIssuerFactory.unpause();
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
}
