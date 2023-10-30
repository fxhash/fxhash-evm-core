// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/splits/SplitsFactory/SplitsFactoryTest.sol";

contract SetController is SplitsFactoryTest {
    bytes4 UNAUTHORIZED_ERROR = bytes4(keccak256("Unauthorized()"));

    function test_SetController() public {
        vm.prank(admin);
        splitsFactory.setController(alice);
    }

    function test_RevertsWhen_NotOwner() public {
        vm.expectRevert(UNAUTHORIZED_ERROR);
        splitsFactory.setController(alice);
    }
}
