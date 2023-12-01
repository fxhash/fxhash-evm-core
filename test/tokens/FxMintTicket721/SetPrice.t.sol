// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract SetPrice is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, PRICE);
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, DEPOSIT_AMOUNT);
        _setTaxInfo();
    }

    function test_SetPrice() public {
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, newPrice);
        _setTaxInfo();
        assertEq(foreclosureTime, taxationStartTime + (ONE_DAY * 2));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function test_RevertsWhen_NotAuthorized() public {
        vm.expectRevert(NOT_AUTHORIZED_TICKET_ERROR);
        TicketLib.setPrice(alice, fxMintTicketProxy, tokenId, newPrice);
    }

    function test_RevertsWhen_Foreclosure() public {
        vm.warp(foreclosureTime);
        vm.expectRevert(FORECLOSURE_ERROR);
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, newPrice);
    }

    function test_RevertsWhen_InvalidPrice() public {
        vm.expectRevert(INVALID_PRICE_ERROR);
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, uint80(MINIMUM_PRICE - 1));
    }

    function test_WhenWithinGracePeriod_IncreasePrice() public {
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, DEPOSIT_AMOUNT);
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, uint80(PRICE * 2));
        _setTaxInfo();
    }

    function test_WhenWithinGracePeriod_DecreasePrice() public {
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, uint80(PRICE / 2));
        _setTaxInfo();

        // assertEq(foreclosureTime, taxationStartTime + (ONE_DAY * 2));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function test_WhenAfterGracePeriod_IncreasePrice() public {
        vm.warp(ONE_DAY);
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, DEPOSIT_AMOUNT);
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, uint80(PRICE * 2));
        _setTaxInfo();
    }

    function test_WhenAfterGracePeriod_DecreasePrice() public {
        vm.warp(ONE_DAY);
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, uint80(PRICE / 2));
        _setTaxInfo();

        // assertEq(foreclosureTime, taxationStartTime + (ONE_DAY * 2));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    /**
     * GRACE PERIOD SCENARIOS
     */
    /// Set Price over Deposit
    function test_Scenarios1() public {
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, 0);
        tokenId++;
        _setTaxInfo();
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, 0.0018 ether);
        _setTaxInfo();
        /// 0.67 * 0.027 == 0.001809 [  User doesnt have enough for 1 day of tax ]
        vm.expectRevert(INSUFFICIENT_DEPOSIT_ERROR);
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, uint80(0.67 ether));
        _setTaxInfo();

        /// 0.66 * 0.027 == 0.001782 [ User has enough for 1 day of tax + the gracePeriod ]
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, uint80(0.66 ether));
        _setTaxInfo();

        assertApproxEqRel(foreclosureTime, block.timestamp + 2 days, 0.01e18);
    }

    function test_Scenarios2() public {
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, 0);
        tokenId++;
        _setTaxInfo();
        /// MIN_PRICE = 0.001 ether * 0.027 == 0.000027 ether daily tax [ User should only have grace period ]
        console.log(foreclosureTime);
        /// Extends foreclosure time based on 0.001 ether
        /// figure out what this should be
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, 0.018 ether);
        _setTaxInfo();
        console.log(foreclosureTime);
        /// 1 ether * 0.027 == 0.027  ether daily tax [  User shouldnt have enough to set this price ]
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, uint80(1 ether));
        _setTaxInfo();
        // assertApproxEqRel(foreclosureTime, block.timestamp + 2 days, 0.01e18);
    }

    function test_Scenarios3() public {
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, 1, 1 ether);
        tokenId++;
        _setTaxInfo();
        /// 1 ether * 0.027 == 0.027 ether daily tax [ User should only have grace period ]
        console.log(foreclosureTime);

        /// This should be insufficient to extend their foreclosureTime / but it extends it 3 days
        /// User should deposit 0.027 ether and extend their foreclosureTime by 1 day
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, 0.018 ether);
        _setTaxInfo();
        console.log(foreclosureTime);
    }

    function test_Scenarios4() public {
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, 0);
        tokenId++;
        _setTaxInfo();
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, 0.0027 ether);
        _setTaxInfo();
        /// 0.66 * 0.027 == 0.001782 [ User has enough for 1 day of tax ]
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, uint80(1 ether));
        _setTaxInfo();
        console.log(foreclosureTime);

        TicketLib.transferFrom(bob, fxMintTicketProxy, bob, address(420), tokenId);
        _setTaxInfo();
        console.log(foreclosureTime);
        /// Foreclosure time should transfer with the token
    }

    function test_Scenarios5() public {
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, 0);
        tokenId++;
        _setTaxInfo();
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, 0.0027 ether);
        _setTaxInfo();
        /// 0.66 * 0.027 == 0.001782 [ User has enough for 1 day of tax ]
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, uint80(1 ether));
        console.log(foreclosureTime);

        /// warp to after grace period
        vm.warp(block.timestamp + 1 days + 1);
        // Pretty sure the below should pass
        // TicketLib.claim(alice, fxMintTicketProxy, tokenId, 0.66 ether, 0.66 ether, 0.66 ether);

        TicketLib.claim(alice, fxMintTicketProxy, tokenId, 1 ether, 1 ether, 1.0027 ether);
        _setTaxInfo();
        console.log(foreclosureTime);
        /// Foreclosure time should transfer with the token
    }

    function test_Scenarios6() public {
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, 0);
        tokenId++;
        _setTaxInfo();
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, 0.0027 ether);
        _setTaxInfo();
        /// 0.66 * 0.027 == 0.001782 [ User has enough for 1 day of tax ]
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, uint80(1 ether));
        _setTaxInfo();
        console.log(foreclosureTime);

        TicketLib.transferFrom(bob, fxMintTicketProxy, bob, bob, tokenId);
        _setTaxInfo();
        console.log(foreclosureTime);
        /// Foreclosure time should transfer with the token
    }

    function test_Scenarios7() public {
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, 0);
        tokenId++;
        _setTaxInfo();
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, 0.0027 ether);
        _setTaxInfo();

        // TicketLib.setPrice(address(this), fxMintTicketProxy, tokenId, uint80(1 ether));
        // _setTaxInfo();

        vm.prank(address(ticketRedeemer));
        IFxMintTicket721(fxMintTicketProxy).burn(tokenId);
        _setTaxInfo();
    }
}
