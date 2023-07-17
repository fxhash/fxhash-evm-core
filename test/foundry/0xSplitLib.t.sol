// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import {Lib0xSplits} from "contracts/libs/Lib0xSplits.sol";
import {ISplitsMain} from "contracts/interfaces/ISplitsMain.sol";

import {Deploy} from "script/Deploy.s.sol";

contract SplitTest is Test, Deploy {
    address[] public accounts;
    uint32[] public allocations;
    bytes32 public salt;

    function setUp() public override {
        accounts.push(address(2));
        accounts.push(address(3));
        allocations.push(uint32(400000));
        allocations.push(uint32(600000));
        salt = Lib0xSplits.getSalt(accounts, allocations, 0);
        mock0xSplits();
    }

    function test_VerifyDeployment() public {
        assertEq(deployedAddress, splitMain);
        assertEq(ISplitsMain(splitMain).walletImplementation(), splitWallet);
    }

    function test_VerifyPredictAddress() public {
        address libPredicted = Lib0xSplits.predictDeterministicAddress(salt);
        address computedAddress = ISplitsMain(splitMain).predictImmutableSplitAddress(
            accounts,
            allocations,
            0
        );
        assertEq(libPredicted, computedAddress);
    }

    function test_FirstWithdraw() public {
        salt = Lib0xSplits.getSalt(accounts, allocations, 0);
        address libPredicted = Lib0xSplits.predictDeterministicAddress(salt);
        vm.deal(libPredicted, 1 ether);
        ISplitsMain(splitMain).createSplit(accounts, allocations, 0, address(0));
        ISplitsMain(splitMain).distributeETH(libPredicted, accounts, allocations, 0, address(0));
        ISplitsMain(splitMain).withdraw(address(2), 0.4 ether, new address[](0));
        ISplitsMain(splitMain).withdraw(address(3), 0.6 ether, new address[](0));
        /// on first withdraw, 1 wei is withheld for gas savings
        assertGt(address(2).balance, 0.3999999 ether);
        assertGt(address(3).balance, 0.5999999 ether);
    }

    function test_2ndWithdraw() public {
        test_FirstWithdraw();
        address computedAddress = ISplitsMain(splitMain).predictImmutableSplitAddress(
            accounts,
            allocations,
            0
        );
        vm.deal(computedAddress, 1 ether);
        ISplitsMain(splitMain).distributeETH(computedAddress, accounts, allocations, 0, address(0));
        uint256 cachedBalance2 = address(2).balance;
        uint256 cachedBalance3 = address(3).balance;
        ISplitsMain(splitMain).withdraw(address(2), 0.4 ether, new address[](0));
        ISplitsMain(splitMain).withdraw(address(3), 0.6 ether, new address[](0));
        /// balance fully availalble
        assertEq(address(2).balance - cachedBalance2, 0.4 ether);
        assertEq(address(3).balance - cachedBalance3, 0.6 ether);
    }
}
