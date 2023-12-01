// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Script.sol";
import "script/utils/Constants.sol";
import "src/utils/Constants.sol";
import "test/utils/Constants.sol";

import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";
import {FxMintTicket721} from "src/tokens/FxMintTicket721.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";

import {LibClone} from "solady/src/utils/LibClone.sol";

contract Deploy is Script {
    // Contract
    FxContractRegistry internal fxContractRegistry;
    FxMintTicket721 internal fxMintTicket721;
    FxRoleRegistry internal fxRoleRegistry;

    // Accounts
    address internal admin;
    address internal creator;

    // State
    address[] internal contracts;
    string[] internal names;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        _createAccounts();
        fxContractRegistry = FxContractRegistry(0xC3D416f526975a9562A235DaCde1Dd07AE511210);
        fxRoleRegistry = FxRoleRegistry(0x6731d1354fA3b2fd6B4f6cB36aE8D602B1652025);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      RUN
    //////////////////////////////////////////////////////////////////////////*/
    function run() public virtual {
        vm.startBroadcast();
        _deployContracts();
        vm.stopBroadcast();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ACCOUNTS
    //////////////////////////////////////////////////////////////////////////*/

    function _createAccounts() internal virtual {
        admin = msg.sender;
        creator = makeAddr("creator");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    DEPLOYMENTS
    //////////////////////////////////////////////////////////////////////////*/

    function _deployContracts() internal virtual {
        bytes32 salt = keccak256(abi.encode(vm.getNonce(admin)));
        bytes memory creationCode = type(FxMintTicket721).creationCode;
        bytes memory constructorArgs = abi.encode(fxContractRegistry, fxRoleRegistry);
        fxMintTicket721 = FxMintTicket721(_deployCreate2(creationCode, constructorArgs, salt));

        vm.label(address(fxMintTicket721), "FxMintTicket721");
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

    function _initCode(bytes memory _creationCode, bytes memory _constructorArgs) internal pure returns (bytes memory) {
        return bytes.concat(_creationCode, _constructorArgs);
    }
}
