// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {FxSplitsFactoryTest} from "test/unit/FxSplitsFactory/FxSplitsFactoryTest.sol";
import {SPLITS_MAIN} from "script/utils/Constants.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";

contract CreateVirtualSplit is FxSplitsFactoryTest {
    function setUp() public override {
        super.setUp();
        accounts.push(address(13));
        accounts.push(address(53));
        allocations.push(uint32(400_000));
        allocations.push(uint32(600_000));
    }

    function test_createsVirtualSplit() public {
        splitsFactory.createVirtualSplit(accounts, allocations);
    }

    function test_RevertsWhen_LengthMismatch() public {
        accounts.pop();

        vm.expectRevert();
        splitsFactory.createVirtualSplit(accounts, allocations);
    }

    function test_RevertsWhen_AllocationsGt100() public {
        accounts.push(address(420));
        allocations.push(1);

        vm.expectRevert();
        splitsFactory.createVirtualSplit(accounts, allocations);
    }

    function test_RevertsWhen_AllocationsLt100() public {
        allocations[0]--;

        vm.expectRevert();
        splitsFactory.createVirtualSplit(accounts, allocations);
    }

    function test_RevertsWhen_DuplicateAccountInAccounts() public {
        accounts.push(address(13));
        allocations.push(1);
        allocations[0]--;

        vm.expectRevert();
        splitsFactory.createVirtualSplit(accounts, allocations);
    }

    function test_RevertsWhen_AccountsNotSorted() public {
        (accounts[0], accounts[1]) = (accounts[1], accounts[0]);

        vm.expectRevert();
        splitsFactory.createVirtualSplit(accounts, allocations);
    }
}
