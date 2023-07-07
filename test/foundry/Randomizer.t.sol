// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Randomizer} from "contracts/randomizer/Randomizer.sol";

contract RandomizerTest is Test {
    address public admin = address(1);
    address public fxHashAdmin = address(2);
    address public addr1 = address(3);
    bytes32 public FXHASH_AUTHORITY;
    bytes32 public FXHASH_ISSUER;

    Randomizer public randomizer;

    function setUp() public virtual {
        randomizer = new Randomizer(keccak256("seed"), keccak256("salt"));
        FXHASH_AUTHORITY = randomizer.FXHASH_AUTHORITY();
        FXHASH_ISSUER = randomizer.FXHASH_ISSUER();
    }
}

contract Generate is RandomizerTest {
    bytes32 public tokenKey;

    function setUp() public virtual override {
        super.setUp();
        tokenKey = randomizer.getTokenKey(fxHashAdmin, 1);
        randomizer.grantFxHashIssuerRole(fxHashAdmin);
    }

    function test_Generate() public {
        vm.prank(fxHashAdmin);
        randomizer.generate(1);
        (bytes32 seed, uint256 serialId, ) = randomizer.seeds(tokenKey);
        assertGt(uint256(seed), 0);
        assertEq(serialId, 1);
    }
}

contract Reveal is RandomizerTest {}

contract Commit is RandomizerTest {}

contract GranFxHashAuthorityRole is RandomizerTest {
    function test_GrantAdminRole() public {
        randomizer.grantFxHashAuthorityRole(fxHashAdmin);

        assertTrue(randomizer.hasRole(FXHASH_AUTHORITY, fxHashAdmin));
    }

    function test_RevertsWhenNotAdmin() public {
        vm.prank(addr1);
        vm.expectRevert();
        randomizer.grantFxHashAuthorityRole(fxHashAdmin);

        assertFalse(randomizer.hasRole(FXHASH_AUTHORITY, fxHashAdmin));
    }
}

contract RevokeFxHashAuthorityRole is RandomizerTest {
    function setUp() public virtual override {
        super.setUp();
        randomizer.grantFxHashAuthorityRole(fxHashAdmin);
    }

    function test_RevokeRole() public {
        randomizer.revokeFxHashAuthorityRole(fxHashAdmin);
    }

    function test_RevertsWhenNotAdmin() public {
        vm.expectRevert();
        vm.prank(addr1);
        randomizer.revokeAdminRole(fxHashAdmin);
    }
}

contract GranFxHashIssuerRole is RandomizerTest {
    function test_GrantAdminRole() public {
        randomizer.grantFxHashIssuerRole(fxHashAdmin);

        assertTrue(randomizer.hasRole(FXHASH_ISSUER, fxHashAdmin));
    }

    function test_RevertsWhenNotAdmin() public {
        vm.prank(addr1);
        vm.expectRevert();
        randomizer.grantFxHashIssuerRole(fxHashAdmin);

        assertFalse(randomizer.hasRole(FXHASH_ISSUER, fxHashAdmin));
    }
}

contract RevokeFxHashIssuerRole is RandomizerTest {
    function setUp() public virtual override {
        super.setUp();
        randomizer.grantFxHashIssuerRole(fxHashAdmin);
    }

    function test_RevokeRole() public {
        randomizer.revokeFxHashIssuerRole(fxHashAdmin);
    }

    function test_RevertsWhenNotAdmin() public {
        vm.expectRevert();
        vm.prank(addr1);
        randomizer.revokeFxHashIssuerRole(fxHashAdmin);
    }
}

contract GetTokenKey is RandomizerTest {
    function test_GetTokenKey() public {
        bytes32 value = randomizer.getTokenKey(address(4), 1);
        assertGt(uint256(value), 0);
    }
}
