// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {FxSplitsFactory} from "src/factories/FxSplitsFactory.sol";
import {BaseTest} from "test/BaseTest.t.sol";
import "src/utils/Constants.sol";
import "script/utils/Constants.sol";

contract FxSplitsFactoryTest is BaseTest {
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
