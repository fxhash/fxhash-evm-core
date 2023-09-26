// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxSplitsFactory/FxSplitsFactoryTest.sol";

contract CreateSplit is FxSplitsFactoryTest {
    function setUp() public virtual override {
        super.setUp();
        accounts.push(address(2));
        accounts.push(address(3));
        allocations.push(uint32(400_000));
        allocations.push(uint32(600_000));
    }

    function test_createSplit() public {
        fxSplitsFactory.createSplit(accounts, allocations);
    }

    function test_RevertsWhen_CreateSplitTwice() public {
        fxSplitsFactory.createSplit(accounts, allocations);
        vm.expectRevert(abi.encodeWithSelector(IFxSplitsFactory.SplitsExists.selector));
        fxSplitsFactory.createSplit(accounts, allocations);
    }

    function test_FirstWithdraw() public {
        address libPredicted =
            ISplitsMain(SPLITS_MAIN).predictImmutableSplitAddress(accounts, allocations, 0);
        vm.deal(libPredicted, 1 ether);
        fxSplitsFactory.createSplit(accounts, allocations);
        ISplitsMain(SPLITS_MAIN).distributeETH(libPredicted, accounts, allocations, 0, address(0));
        ISplitsMain(SPLITS_MAIN).withdraw(address(2), 0.4 ether, new address[](0));
        ISplitsMain(SPLITS_MAIN).withdraw(address(3), 0.6 ether, new address[](0));
        /// on first withdraw, 1 wei is withheld for gas savings
        assertGt(address(2).balance, 0.3999999 ether);
        assertGt(address(3).balance, 0.5999999 ether);
    }

    function test_2ndWithdraw() public {
        test_FirstWithdraw();
        address computedAddress =
            ISplitsMain(SPLITS_MAIN).predictImmutableSplitAddress(accounts, allocations, 0);
        vm.deal(computedAddress, 1 ether);
        ISplitsMain(SPLITS_MAIN).distributeETH(
            computedAddress, accounts, allocations, 0, address(0)
        );
        uint256 cachedBalance2 = address(2).balance;
        uint256 cachedBalance3 = address(3).balance;
        ISplitsMain(SPLITS_MAIN).withdraw(address(2), 0.4 ether, new address[](0));
        ISplitsMain(SPLITS_MAIN).withdraw(address(3), 0.6 ether, new address[](0));
        /// balance fully availalble
        assertEq(address(2).balance - cachedBalance2, 0.4 ether);
        assertEq(address(3).balance - cachedBalance3, 0.6 ether);
    }

    function test_RevertsWhen_LengthMismatch() public {
        accounts.pop();

        vm.expectRevert();
        fxSplitsFactory.createSplit(accounts, allocations);
    }

    function test_RevertsWhen_AllocationsGt100() public {
        accounts.push(address(420));
        allocations.push(1);

        vm.expectRevert();
        fxSplitsFactory.createSplit(accounts, allocations);
    }

    function test_RevertsWhen_AllocationsLt100() public {
        allocations[0]--;

        vm.expectRevert();
        fxSplitsFactory.createSplit(accounts, allocations);
    }

    function test_RevertsWhen_DuplicateAccountInAccounts() public {
        accounts.push(address(2));
        allocations.push(1);
        allocations[0]--;

        vm.expectRevert();
        fxSplitsFactory.createSplit(accounts, allocations);
    }

    function test_RevertsWhen_AccountsNotSorted() public {
        (accounts[0], accounts[1]) = (accounts[1], accounts[0]);

        vm.expectRevert();
        fxSplitsFactory.createSplit(accounts, allocations);
    }
}
