// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Script.sol";
import "script/utils/Constants.sol";
import "src/utils/Constants.sol";

import {FarcasterFrameV1} from "src/minters/v1/FarcasterFrameV1.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";

contract Farcaster is Script {
    // Contracts
    FarcasterFrameV1 internal farcasterFrame;
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
        if (block.chainid == BASE_SEPOLIA) {
            fxRoleRegistry = FxRoleRegistry(BASE_SEPOLIA_FX_ROLE_REGISTRY);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    DEPLOYMENTS
    //////////////////////////////////////////////////////////////////////////*/

    function _deployContracts() internal virtual {
        bytes32 salt = keccak256(abi.encode(vm.getNonce(admin)));

        // SignatureFrame
        bytes memory creationCode = type(FarcasterFrameV1).creationCode;
        bytes memory constructorArgs = abi.encode(admin, FRAME_CONTROLLER);
        farcasterFrame = FarcasterFrameV1(_deployCreate2(creationCode, constructorArgs, salt));

        vm.label(address(farcasterFrame), "FarcasterFrameV1");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SETTERS
    //////////////////////////////////////////////////////////////////////////*/

    function _grantRoles() internal virtual {
        fxRoleRegistry.grantRole(MINTER_ROLE, address(farcasterFrame));
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
