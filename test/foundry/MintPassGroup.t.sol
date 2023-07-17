// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {MintPassGroup} from "contracts/mint-pass-group/MintPassGroup.sol";

contract MintPassGroupTest is Test {
    address public admin =
        vm.addr(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
    bytes32 public fxHashAdminPk =
        0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    address public fxHashAdmin = vm.addr(uint256(fxHashAdminPk));
    address public user1 =
        vm.addr(0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a);
    address public user2 =
        vm.addr(0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6);

    /// project details
    string public token = "TOKEN1";
    address public project = address(1);
    address public addr = user1;

    MintPassGroup public mintPassGroup;

    function setUp() public virtual {
        mintPassGroup = new MintPassGroup(
            10 /* maxPerToken */,
            5 /* maxPerTokenPerProject */,
            fxHashAdmin /* signer (authorized caller)*/,
            fxHashAdmin /* reserve Mint pass*/,
            new address[](0) /* bypass array */
        );
    }
}

contract GetProjectHash is MintPassGroupTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract IsValidPass is MintPassGroupTest {
    function test_RevertsWhenSignatureInvalid() public {
        bytes memory payload = abi.encode(MintPassGroup.Payload(token, project, addr));
        bytes memory pass = abi.encode(MintPassGroup.Pass(payload, ""));
        vm.expectRevert("PASS_INVALID_SIGNATURE");
        mintPassGroup.isPassValid(pass, addr);
    }
}

contract ConsumePass is MintPassGroupTest {
    function test_RevertsWhenSignatureInvalid() public {
        bytes memory payload = abi.encode(MintPassGroup.Payload(token, project, addr));
        bytes memory pass = abi.encode(MintPassGroup.Pass(payload, ""));
        /// this is the 2nd Admin (mintPass)
        vm.prank(fxHashAdmin);
        vm.expectRevert("PASS_INVALID_SIGNATURE");
        mintPassGroup.consumePass(pass, addr);
    }
}

contract SetConstraints is MintPassGroupTest {
    function test_RevertsWhenNotAuthorized() public {
        vm.prank(address(420));
        vm.expectRevert();
        mintPassGroup.setConstraints(1, 1);
        /// check constraints
    }

    function test_setConstraints() public {
        mintPassGroup.setConstraints(1, 1);
        /// check constraints
    }
}

contract SetBypass is MintPassGroupTest {
    function test_RevertsWhenNotAuthorized() public {
        address[] memory bypassArray = new address[](1);
        bypassArray[0] = fxHashAdmin;
        vm.prank(address(420));
        vm.expectRevert();
        mintPassGroup.setBypass(bypassArray);
    }

    function test_setBypass() public {
        address[] memory bypassArray = new address[](1);
        bypassArray[0] = fxHashAdmin;
        mintPassGroup.setBypass(bypassArray);
        assertTrue(mintPassGroup.getBypass().length == 1, "Bypass array not set");
        /// check contents
    }

    function test_whenExists() public {
        address[] memory bypassArray = new address[](1);
        bypassArray[0] = fxHashAdmin;
        mintPassGroup.setBypass(bypassArray);
        mintPassGroup.setBypass(bypassArray);
    }
}

contract GetBypass is MintPassGroupTest {
    function test_whenEmpty() public {
        assertTrue(mintPassGroup.getBypass().length == 0, "Bypass array not 0");
    }

    function test_whenSet() public {
        address[] memory bypassArray = new address[](1);
        bypassArray[0] = fxHashAdmin;
        mintPassGroup.setBypass(bypassArray);
        assertTrue(mintPassGroup.getBypass().length == 1, "Bypass array not set");
    }
}
