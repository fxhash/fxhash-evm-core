// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC721} from "forge-std/interfaces/IERC721.sol";
import "test/unit/FxMintTicket721/FxMintTicket721Test.t.sol";

contract Burn is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        _mint(alice, bob, amount, PRICE);
        _setTaxInfo();
    }

    function testBurn() public {
        vm.prank(bob);
        IERC721(fxMintTicketProxy).approve(minter, tokenId);
        _burn(bob, tokenId);
        _setTaxInfo();
        assertEq(gracePeriod, 0);
        assertEq(foreclosureTime, 0);
        assertEq(currentPrice, 0);
        assertEq(depositAmount, 0);
    }

    function testBurn_RevertsWhen_NotAuthorized() public {
        vm.expectRevert("ERC721: caller is not token owner or approved");
        _burn(bob, tokenId);
    }
}
