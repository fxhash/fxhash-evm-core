// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {FxSplitsFactory} from "src/factories/FxSplitsFactory.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";

contract FxSplitsFactoryTest is BaseTest {
    error InvalidSplit__TooFewAccounts(uint256 accountsLength);
    error InvalidSplit__AccountsAndAllocationsMismatch(
        uint256 accountsLength, uint256 allocationsLength
    );
    error InvalidSplit__InvalidAllocationsSum(uint32 allocationsSum);
    error InvalidSplit__AccountsOutOfOrder(uint256 index);
    error InvalidSplit__AllocationMustBePositive(uint256 index);
    error InvalidSplit__InvalidDistributorFee(uint32 distributorFee);

    FxSplitsFactory public splitsFactory;
    address[] public accounts;
    uint32[] public allocations;

    function setUp() public virtual override {
        _mock0xSplits();
        splitsFactory = new FxSplitsFactory();
    }

    function _mock0xSplits() internal {
        bytes memory splitMainBytecode = abi.encodePacked(SPLITS_MAIN_CREATION_CODE, abi.encode());
        address deployedAddress_;
        // original deployer + original nonce used at deployment
        vm.startPrank(SPLITS_DEPLOYER);
        vm.setNonce(SPLITS_DEPLOYER, SPLITS_DEPLOYER_NONCE);
        assembly {
            deployedAddress_ := create(0, add(splitMainBytecode, 32), mload(splitMainBytecode))
        }
    }
}
