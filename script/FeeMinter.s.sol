// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Script.sol";
import "script/utils/Constants.sol";
import "src/utils/Constants.sol";

import {DutchAuctionV2} from "src/minters/DutchAuctionV2.sol";
import {FeeManager} from "src/minters/extensions/FeeManager.sol";
import {FixedPriceV2} from "src/minters/FixedPriceV2.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";

contract MinterFee is Script {
    // Contracts
    DutchAuctionV2 internal dutchAuction;
    FeeManager internal feeManager;
    FixedPriceV2 internal fixedPrice;
    FxRoleRegistry internal fxRoleRegistry;

    // State
    address internal admin;

    /*//////////////////////////////////////////////////////////////////////////
                                      RUN
    //////////////////////////////////////////////////////////////////////////*/

    function run() public virtual {
        vm.startBroadcast();
        _deployContracts();
        _grantRoles();
        vm.stopBroadcast();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        admin = msg.sender;
        if (block.chainid == MAINNET) {
            fxRoleRegistry = FxRoleRegistry(MAINNET_FX_ROLE_REGISTRY);
        } else if (block.chainid == SEPOLIA) {
            fxRoleRegistry = FxRoleRegistry(SEPOLIA_FX_ROLE_REGISTRY);
        } else if (block.chainid == BASE_MAINNET) {
            fxRoleRegistry = FxRoleRegistry(BASE_MAINNET_FX_ROLE_REGISTRY);
        } else if (block.chainid == BASE_SEPOLIA) {
            fxRoleRegistry = FxRoleRegistry(BASE_SEPOLIA_FX_ROLE_REGISTRY);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    DEPLOYMENTS
    //////////////////////////////////////////////////////////////////////////*/

    function _deployContracts() internal virtual {
        // FeeManager
        bytes32 salt = keccak256(abi.encode(vm.getNonce(admin)));
        bytes memory creationCode = type(FeeManager).creationCode;
        bytes memory constructorArgs = abi.encode(admin, PLATFORM_FEE, MINT_PERCENTAGE, SPLIT_PERCENTAGE);
        feeManager = FeeManager(payable(_deployCreate2(creationCode, constructorArgs, salt)));

        // DutchAuctionV2
        creationCode = type(DutchAuctionV2).creationCode;
        constructorArgs = abi.encode(admin, feeManager);
        dutchAuction = DutchAuctionV2(_deployCreate2(creationCode, constructorArgs, salt));

        // FixedPriceV2
        creationCode = type(FixedPriceV2).creationCode;
        constructorArgs = abi.encode(admin, FRAME_CONTROLLER, feeManager);
        fixedPrice = FixedPriceV2(_deployCreate2(creationCode, constructorArgs, salt));

        vm.label(address(dutchAuction), "DutchAuctionV2");
        vm.label(address(feeManager), "FeeManager");
        vm.label(address(fixedPrice), "FixedPriceV2");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SETTERS
    //////////////////////////////////////////////////////////////////////////*/

    function _grantRoles() internal virtual {
        fxRoleRegistry.grantRole(MINTER_ROLE, address(dutchAuction));
        fxRoleRegistry.grantRole(MINTER_ROLE, address(fixedPrice));
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
}
