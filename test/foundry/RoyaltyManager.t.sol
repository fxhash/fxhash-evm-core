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

    function test_RevertsWhen_BaseRoyaltiesAlreadySet() public {
        royaltyManager.setBaseRoyalties(accounts, basisPoints);
        vm.expectRevert(abi.encodeWithSelector(IRoyaltyManager.BaseRoyaltiesAlreadySet.selector));
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

    function test_RevertsWhen_TokenRoyaltiesAlreadySet() public {
        royaltyManager.setTokenRoyalties(tokenId, accounts, basisPoints);

        vm.expectRevert(abi.encodeWithSelector(IRoyaltyManager.TokenRoyaltiesAlreadySet.selector));
        royaltyManager.setTokenRoyalties(tokenId, accounts, basisPoints);
    }
}

contract ResetDefaultRoyalties is RoyaltyManagerTest {
    function setUp() public override {
        super.setUp();
        accounts.push(payable(address(40)));
        accounts.push(payable(address(20)));
        accounts.push(payable(address(10)));

        basisPoints.push(1500);
        basisPoints.push(1500);
        basisPoints.push(1500);

        royaltyManager.setBaseRoyalties(accounts, basisPoints);
    }

    function test_ResetBaseRoyalty() public {
        royaltyManager.deleteBaseRoyalty();
    }

    function test_RevertsWhen_NotSet() public {
        royaltyManager.deleteBaseRoyalty();

        vm.expectRevert(abi.encodeWithSelector(IRoyaltyManager.BaseRoyaltiesNotSet.selector));
        royaltyManager.deleteBaseRoyalty();
    }
}

contract ResetTokenRoyalties is RoyaltyManagerTest {
    function setUp() public override {
        super.setUp();
        tokenId = 1;
        MockRoyaltyManager(address(royaltyManager)).setTokenExists(tokenId, true);
        accounts.push(payable(address(42)));

        basisPoints.push(2500);
        royaltyManager.setTokenRoyalties(tokenId, accounts, basisPoints);
    }

    function test_ResetTokenRoyalty() public {
        royaltyManager.deleteTokenRoyalty(tokenId);
    }

    function test_RevertsWhen_NotSet() public {
        royaltyManager.deleteTokenRoyalty(tokenId);

        vm.expectRevert(abi.encodeWithSelector(IRoyaltyManager.TokenRoyaltiesNotSet.selector));
        royaltyManager.deleteTokenRoyalty(tokenId);
    }

    function test_RevertsWhen_TokenDoesntExist() public {
        tokenId = 2;

        vm.expectRevert(abi.encodeWithSelector(IRoyaltyManager.NonExistentToken.selector));
        royaltyManager.deleteTokenRoyalty(tokenId);
    }
}
