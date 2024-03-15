// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Script.sol";
import "script/utils/Constants.sol";
import "src/utils/Constants.sol";

import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";

import {PayableFrame} from "src/minters/PayableFrame.sol";
import {SignatureFrame} from "src/minters/SignatureFrame.sol";

contract Farcaster is Script {
    // Core
    FxContractRegistry internal fxContractRegistry;
    FxRoleRegistry internal fxRoleRegistry;

    // Periphery
    PayableFrame internal payableFrame;
    SignatureFrame internal signatureFrame;

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
        fxContractRegistry = FxContractRegistry(0x58acdAaab9119e82c179Fa63FB1B4295e2dc127a);
        fxRoleRegistry = FxRoleRegistry(0xB809Cd1675bb6a200128661C5A8e342a64a01748);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    DEPLOYMENTS
    //////////////////////////////////////////////////////////////////////////*/

    function _deployContracts() internal virtual {
        bytes32 salt = keccak256(abi.encode(vm.getNonce(admin)));

        // SignatureFrame
        bytes memory creationCode = type(SignatureFrame).creationCode;
        bytes memory constructorArgs = abi.encode(SIGNER);
        signatureFrame = SignatureFrame(_deployCreate2(creationCode, constructorArgs, salt));

        // PayableFrame
        creationCode = type(PayableFrame).creationCode;
        payableFrame = PayableFrame(_deployCreate2(creationCode, salt));

        vm.label(address(payableFrame), "PayableFrame");
        vm.label(address(signatureFrame), "SignatureFrame");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SETTERS
    //////////////////////////////////////////////////////////////////////////*/

    function _grantRoles() internal virtual {
        fxRoleRegistry.grantRole(MINTER_ROLE, address(payableFrame));
        fxRoleRegistry.grantRole(MINTER_ROLE, address(signatureFrame));
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
