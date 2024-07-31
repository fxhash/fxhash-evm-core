// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Script.sol";
import "script/utils/Constants.sol";
import "script/utils/Contracts.sol";
import "src/utils/Constants.sol";

import {FixedPriceParamsV1} from "src/minters/v1/FixedPriceParamsV1.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";

contract Custom is Script {
    // Contracts
    FixedPriceParamsV1 internal fixedPriceParams;
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
        if (block.chainid == SEPOLIA) {
            fxRoleRegistry = FxRoleRegistry(SEPOLIA_FX_ROLE_REGISTRY);
        } else if (block.chainid == BASE_SEPOLIA) {
            fxRoleRegistry = FxRoleRegistry(BASE_SEPOLIA_FX_ROLE_REGISTRY);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    DEPLOYMENTS
    //////////////////////////////////////////////////////////////////////////*/

    function _deployContracts() internal virtual {
        bytes32 salt = keccak256(abi.encode(vm.getNonce(admin)));
        bytes memory creationCode = type(FixedPriceParamsV1).creationCode;
        fixedPriceParams = FixedPriceParamsV1(_deployCreate2(creationCode, salt));

        vm.label(address(fixedPriceParams), "FixedPriceParamsV1");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SETTERS
    //////////////////////////////////////////////////////////////////////////*/

    function _grantRoles() internal virtual {
        fxRoleRegistry.grantRole(MINTER_ROLE, address(fixedPriceParams));
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
