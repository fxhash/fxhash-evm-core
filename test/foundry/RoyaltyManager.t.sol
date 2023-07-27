// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {MockRoyaltyManager} from "test/foundry/mocks/MockRoyaltyManager.sol";
import {IRoyaltyManager} from "contracts/interfaces/IRoyaltyManager.sol";

contract RoyaltyManagerTest is Test {
    uint256 tokenId;
    address payable[] public accounts;
    uint96[] public basisPoints;
    IRoyaltyManager public royaltyManager;

    function setUp() public virtual {
        royaltyManager = IRoyaltyManager(new MockRoyaltyManager());
    }
}

contract SetBaseRoyaltiesTest is RoyaltyManagerTest {
    function setUp() public override {
        super.setUp();
        accounts.push(payable(address(40)));
        accounts.push(payable(address(20)));
        accounts.push(payable(address(10)));

        basisPoints.push(2500);
        basisPoints.push(2500);
        basisPoints.push(2500);
    }

    function test_SetBaseRoyalties() public {
        royaltyManager.setBaseRoyalties(accounts, basisPoints);
    }

    function test_RevertsWhen_SingleGt25() public {
        basisPoints[0] = 2501;
        vm.expectRevert(abi.encodeWithSelector(IRoyaltyManager.OverMaxBasisPointAllowed.selector));
        royaltyManager.setBaseRoyalties(accounts, basisPoints);
    }

    function test_RevertsWhen_AllGt100() public {
        basisPoints.push(2500);
        accounts.push(payable(address(1)));
        basisPoints.push(1);
        accounts.push(payable(address(0xBad)));
        vm.expectRevert(abi.encodeWithSelector(IRoyaltyManager.InvalidRoyaltyConfig.selector));
        royaltyManager.setBaseRoyalties(accounts, basisPoints);
    }

    function test_RevertsWhen_LengthMismatchAccounts() public {
        accounts.pop();
        vm.expectRevert(abi.encodeWithSelector(IRoyaltyManager.LengthMismatch.selector));
        royaltyManager.setBaseRoyalties(accounts, basisPoints);
    }

    function test_RevertsWhen_LengthMismatchBasisPoints() public {
        basisPoints.pop();
        vm.expectRevert(abi.encodeWithSelector(IRoyaltyManager.LengthMismatch.selector));
        royaltyManager.setBaseRoyalties(accounts, basisPoints);
    }
}

contract SetTokenRoyaltiesTest is RoyaltyManagerTest {
    function setUp() public override {
        super.setUp();
        tokenId = 1;
        MockRoyaltyManager(address(royaltyManager)).setTokenExists(tokenId, true);
        accounts.push(payable(address(42)));

        basisPoints.push(2500);
    }

    function test_SetTokenRoyalties() public {
        royaltyManager.setTokenRoyalties(tokenId, accounts, basisPoints);
    }

    function test_RevertsWhen_TokenDoesntExist() public {
        tokenId = 2;
        vm.expectRevert(abi.encodeWithSelector(IRoyaltyManager.NonExistentToken.selector));
        royaltyManager.setTokenRoyalties(tokenId, accounts, basisPoints);
    }

    function test_RevertsWhen_SingleGt25() public {
        basisPoints[0] = 2501;
        vm.expectRevert(abi.encodeWithSelector(IRoyaltyManager.OverMaxBasisPointAllowed.selector));
        royaltyManager.setTokenRoyalties(tokenId, accounts, basisPoints);
    }

    function test_RevertsWhen_TokenAndBaseGt100() public {
        /// Get royalty Config to 100 without being over on any individual one
        accounts.push(payable(address(40)));
        accounts.push(payable(address(20)));
        accounts.push(payable(address(10)));

        basisPoints.push(2500);
        basisPoints.push(2500);
        basisPoints.push(2500);
        accounts.push(payable(address(0xbad)));
        basisPoints.push(1);

        vm.expectRevert(abi.encodeWithSelector(IRoyaltyManager.InvalidRoyaltyConfig.selector));
        royaltyManager.setTokenRoyalties(tokenId, accounts, basisPoints);
    }

    function test_RevertsWhen_LengthMismatchAccounts() public {
        accounts.push(payable(address(40)));
        vm.expectRevert(abi.encodeWithSelector(IRoyaltyManager.LengthMismatch.selector));
        royaltyManager.setTokenRoyalties(tokenId, accounts, basisPoints);
    }

    function test_RevertsWhen_LengthMismatchBasisPoints() public {
        basisPoints.push(2500);
        vm.expectRevert(abi.encodeWithSelector(IRoyaltyManager.LengthMismatch.selector));
        royaltyManager.setTokenRoyalties(tokenId, accounts, basisPoints);
    }
}

contract GetRoyalties is RoyaltyManagerTest {
    function setUp() public override {
        super.setUp();
        accounts.push(payable(address(40)));
        accounts.push(payable(address(20)));
        accounts.push(payable(address(10)));

        basisPoints.push(2500);
        basisPoints.push(2500);
        basisPoints.push(2500);
    }

    function test_getRoyalties() public {
        royaltyManager.setBaseRoyalties(accounts, basisPoints);
        address payable[] memory receivers;
        uint256[] memory bps;
        (receivers, bps) = royaltyManager.getRoyalties(tokenId);
        assertEq(receivers.length, accounts.length, "accounts mismatch");
        assertEq(basisPoints.length, bps.length, "Basispoint mismatch");
    }
}

contract RoyaltyInfo is RoyaltyManagerTest {
    function setUp() public override {
        super.setUp();
        accounts.push(payable(address(10)));
        basisPoints.push(2500);
    }

    function test_WhenBaseLength1() public {
        royaltyManager.setBaseRoyalties(accounts, basisPoints);
        royaltyManager.royaltyInfo(tokenId, 100);
    }

    function test_WhenBaseLength0() public {
        accounts.pop();
        basisPoints.pop();
        royaltyManager.setBaseRoyalties(accounts, basisPoints);
        (address receiver, uint256 bps) = royaltyManager.royaltyInfo(tokenId, 100);
        assertEq(receiver, address(0));
        assertEq(bps, 0);
    }

    function test_RevertsWhenBaseLengthGt1() public {
        accounts.push(payable(address(42)));
        basisPoints.push(1000);
        royaltyManager.setBaseRoyalties(accounts, basisPoints);
        vm.expectRevert(
            abi.encodeWithSelector(IRoyaltyManager.MoreThanOneRoyaltyReceiver.selector)
        );
        royaltyManager.royaltyInfo(tokenId, 100);
    }
}