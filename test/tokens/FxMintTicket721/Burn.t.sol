// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";
import {ERC721} from "openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Burn is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, PRICE);
        _setTaxInfo();
    }

    function test_Burn() public {
        TicketLib.redeem(bob, address(ticketRedeemer), fxGenArtProxy, bob, tokenId, fxParams);
        _setTaxInfo();
        assertEq(taxationStartTime, 0);
        assertEq(foreclosureTime, 0);
        assertEq(currentPrice, 0);
        assertEq(depositAmount, 0);
        assertEq(FxMintTicket721(fxMintTicketProxy).balanceOf(bob), 0);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(bob), 1);
    }

    function test_Burn2() public {
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, 0.0027 ether);
        console.log(ERC721(fxMintTicketProxy).ownerOf(tokenId));

        console.log(IFxMintTicket721(fxMintTicketProxy).totalSupply());
        _setTaxInfo();

        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, uint80(1 ether));
        _setTaxInfo();

        TicketLib.redeem(bob, address(ticketRedeemer), fxGenArtProxy, bob, tokenId, fxParams);
        _setTaxInfo();
    }
}
