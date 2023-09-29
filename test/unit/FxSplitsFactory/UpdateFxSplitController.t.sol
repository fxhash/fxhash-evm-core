// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxSplitsFactory/FxSplitsFactoryTest.sol";

contract UpdateFxSplitController is FxSplitsFactoryTest {
    function test_UpdateFxSplitController() public {
        vm.prank(admin);
        fxSplitsFactory.updateFxSplitController(alice);
    }

    function test_RevertsWhen_NotOwner_UpdateFxSplitController() public {
        vm.expectRevert("Ownable: caller is not the owner");
        fxSplitsFactory.updateFxSplitController(alice);
    }
}
