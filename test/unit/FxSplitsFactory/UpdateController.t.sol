// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxSplitsFactory/FxSplitsFactoryTest.sol";

contract UpdateController is FxSplitsFactoryTest {
    function test_UpdateController() public {
        vm.prank(admin);
        fxSplitsFactory.updateController(alice);
    }

    function test_RevertsWhen_NotOwner_UpdateController() public {
        vm.expectRevert("Ownable: caller is not the owner");
        fxSplitsFactory.updateController(alice);
    }
}
