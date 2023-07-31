// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Randomizer} from "contracts/issuer/Randomizer.sol";

contract RandomizerTest is Test {
    address public admin = address(1);
    address public fxHashAdmin = address(2);
    address public addr1 = address(3);
    bytes32 public FXHASH_AUTHORITY;
    bytes32 public AUTHORIZED_CALLER;

    Randomizer public randomizer;

    function setUp() public virtual {
        randomizer = new Randomizer(keccak256("seed"), keccak256("salt"));
        FXHASH_AUTHORITY = randomizer.DEFAULT_ADMIN_ROLE();
        AUTHORIZED_CALLER = randomizer.AUTHORIZED_CALLER();
    }
}

contract Generate is RandomizerTest {
    bytes32 public tokenKey;

    function setUp() public virtual override {
        super.setUp();
        tokenKey = randomizer.getTokenKey(fxHashAdmin, 1);
        randomizer.grantAuthorizedCallerRole(fxHashAdmin);
    }

    function test_Generate() public {
        vm.prank(fxHashAdmin);
        randomizer.generate(1);
    }
}

contract Reveal is RandomizerTest {}

contract Commit is RandomizerTest {}

contract GrantFxHashAuthorityRole is RandomizerTest {
    function test_GrantAdminRole() public {
        randomizer.grantAdminRole(fxHashAdmin);

        assertTrue(randomizer.hasRole(FXHASH_AUTHORITY, fxHashAdmin));
    }

    function test_RevertsWhenNotAdmin() public {
        vm.prank(addr1);
        vm.expectRevert();
        randomizer.grantAdminRole(fxHashAdmin);

        assertFalse(randomizer.hasRole(FXHASH_AUTHORITY, fxHashAdmin));
    }
}

contract RevokeFxHashAuthorityRole is RandomizerTest {
    function setUp() public virtual override {
        super.setUp();
        randomizer.grantAdminRole(fxHashAdmin);
    }

    function test_RevokeRole() public {
        randomizer.revokeAdminRole(fxHashAdmin);
    }

    function test_RevertsWhenNotAdmin() public {
        vm.expectRevert();
        vm.prank(addr1);
        randomizer.revokeAdminRole(fxHashAdmin);
    }
}

contract GrantFxHashIssuerRole is RandomizerTest {
    function test_GrantAdminRole() public {
        randomizer.grantAuthorizedCallerRole(fxHashAdmin);

        assertTrue(randomizer.hasRole(AUTHORIZED_CALLER, fxHashAdmin));
    }

    function test_RevertsWhenNotAdmin() public {
        vm.prank(addr1);
        vm.expectRevert();
        randomizer.grantAuthorizedCallerRole(fxHashAdmin);

        assertFalse(randomizer.hasRole(AUTHORIZED_CALLER, fxHashAdmin));
    }
}

contract RevokeFxHashIssuerRole is RandomizerTest {
    function setUp() public virtual override {
        super.setUp();
        randomizer.grantAuthorizedCallerRole(fxHashAdmin);
    }

    function test_RevokeRole() public {
        randomizer.revokeAuthorizedCallerRole(fxHashAdmin);
    }

    function test_RevertsWhenNotAdmin() public {
        vm.expectRevert();
        vm.prank(addr1);
        randomizer.revokeAuthorizedCallerRole(fxHashAdmin);
    }
}

contract GetTokenKey is RandomizerTest {
    function test_GetTokenKey() public {
        bytes32 value = randomizer.getTokenKey(address(4), 1);
        assertGt(uint256(value), 0);
    }
}
