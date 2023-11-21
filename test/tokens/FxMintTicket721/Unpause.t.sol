// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract UnpausedTest is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
    }

    function test_Unpause() public {
        TokenLib.pause(admin, address(fxMintTicket721));

        TokenLib.unpause(admin, address(fxMintTicket721));
    }

    function test_Unpause_RevertsWhen_NotModerator() public {
        TokenLib.pause(admin, address(fxMintTicket721));

        vm.expectRevert(UNAUTHORIZED_ACCOUNT_TICKET_ERROR);
        TokenLib.unpause(bob, address(fxMintTicket721));
    }

    function test_Unpause_RevertsWhen_NotPaused() public {
        vm.expectRevert("Pausable: not paused");
        TokenLib.unpause(admin, address(fxMintTicket721));
    }
}
