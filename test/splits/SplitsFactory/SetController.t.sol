// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/splits/SplitsFactory/SplitsFactoryTest.sol";

contract SetController is SplitsFactoryTest {
    function test_SetController() public {
        vm.prank(admin);
        splitsFactory.setController(alice);
    }

    function test_RevertsWhen_NotOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        splitsFactory.setController(alice);
    }
}
