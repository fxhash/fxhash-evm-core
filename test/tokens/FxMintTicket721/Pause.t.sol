// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";

contract Pause is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
    }

    function test_Pause() public {
        TokenLib.pause(admin, address(fxMintTicket721));

        assertTrue(Pausable(fxMintTicket721).paused());
    }

    function test_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_TICKET_ERROR);
        TokenLib.pause(bob, address(fxMintTicket721));
    }

    function test_RevertsWhen_Paused() public {
        TokenLib.pause(admin, address(fxMintTicket721));

        vm.expectRevert("Pausable: paused");
        TokenLib.pause(admin, address(fxMintTicket721));
    }
}
