// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Script.sol";
import "script/utils/Constants.sol";
import "src/utils/Constants.sol";

import {FixedPriceParams} from "src/minters/FixedPriceParams.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";

contract Custom is Script {
    // Core
    FxRoleRegistry internal fxRoleRegistry;

    // Periphery
    FixedPriceParams internal fixedPriceParams;

    // State
    address internal admin;
    address[] internal contracts;
    string[] internal names;

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
            fxRoleRegistry = FxRoleRegistry(0x92B70c5C6E676BdC395DfD911c07392fc7C36E4F);
        } else if (block.chainid == BASE_SEPOLIA) {
            fxRoleRegistry = FxRoleRegistry(0xB809Cd1675bb6a200128661C5A8e342a64a01748);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    DEPLOYMENTS
    //////////////////////////////////////////////////////////////////////////*/

    function _deployContracts() internal virtual {
        bytes32 salt = keccak256(abi.encode(vm.getNonce(admin)));

        // FixedPriceParams
        bytes memory creationCode = type(FixedPriceParams).creationCode;
        fixedPriceParams = FixedPriceParams(_deployCreate2(creationCode, salt));

        vm.label(address(fixedPriceParams), "FixedPriceParams");
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
