// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/factories/SplitsFactory/SplitsFactoryTest.sol";

contract UpdateController is SplitsFactoryTest {
    function test_UpdateController() public {
        vm.prank(admin);
        splitsFactory.updateController(alice);
    }

    function test_RevertsWhen_NotOwner_UpdateController() public {
        vm.expectRevert("Ownable: caller is not the owner");
        splitsFactory.updateController(alice);
    }
}
