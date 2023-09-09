// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "script/Deploy.s.sol";
import {IFxSplitsFactory} from "src/interfaces/IFxSplitsFactory.sol";

contract FxSplitsFactoryGas is Deploy {
    function setUp() public override {
        _mock0xSplits();
        Deploy.setUp();
        _deployContracts();
    }

    function test_CreateSplit() public {
        fxSplitsFactory.createSplit(accounts, allocations);
    }

    function test_CreateVirtualSplit() public {
        fxSplitsFactory.createVirtualSplit(accounts, allocations);
    }

    function test_Revert_CreateSplit() public {
        vm.pauseGasMetering();
        fxSplitsFactory.createSplit(accounts, allocations);

        vm.resumeGasMetering();
        vm.expectRevert(abi.encodeWithSelector(IFxSplitsFactory.SplitsExists.selector));
        fxSplitsFactory.createSplit(accounts, allocations);
    }

    function _mock0xSplits() internal {
        bytes memory splitMainBytecode = abi.encodePacked(SPLITS_MAIN_CREATION_CODE, abi.encode());
        address deployedAddress_;
        vm.prank(SPLITS_DEPLOYER);
        vm.setNonce(SPLITS_DEPLOYER, SPLITS_DEPLOYER_NONCE);
        assembly {
            deployedAddress_ := create(0, add(splitMainBytecode, 32), mload(splitMainBytecode))
        }
    }
}
