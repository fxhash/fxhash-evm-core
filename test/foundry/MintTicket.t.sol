// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {IMintTicket} from "contracts/interfaces/IMintTicket.sol";
import {MintTicket} from "contracts/mint-ticket/MintTicket.sol";
import {Randomizer} from "contracts/randomizer/Randomizer.sol";
import {Constants} from "script/Constants.sol";
import {Accounts} from "script/Accounts.s.sol";

import "hardhat/console.sol";
contract MintTicketTest is Test, Accounts {
    event TicketCreated(address issuer, uint256 gracingPeriod);
    event TicketMinted(address issuer, address minter, uint256 price);
    event PriceUpdated(uint256 tokenId, uint256 price, uint256 coverage);
    event TaxPayed(uint256 tokenId);
    event TicketClaimed(uint256 tokenId, uint256 price, uint256 coverage, address transferTo);
    event TicketConsumed(address owner, uint256 tokenId, address issuer);

    MintTicket public mintTicket;
    Randomizer public randomizer;

    // Additional state variables
    uint256 public constant GRACING_PERIOD = 30;
    uint256 public constant TICKET_PRICE = 1000;

    function setUp() public override {
        createAccounts();
        // Randomizer
        randomizer = new Randomizer(Constants.SEED, Constants.SALT);
        mintTicket = new MintTicket(
            address(randomizer),
            Constants.MINT_TICKET_FEES,
            Constants.MINT_TICKET_MIN_PRICE
        );
    }
}

contract MintTicketTestCreateProject is MintTicketTest {
    function test_createProject() public {
        vm.prank(alice);
        vm.expectEmit(true, true, false, true, address(mintTicket));
        emit TicketCreated(alice, GRACING_PERIOD);
        mintTicket.createTicket(GRACING_PERIOD);
        uint256 storedGracingPeriod = mintTicket.tickets(alice);
        assertTrue(storedGracingPeriod == GRACING_PERIOD, "Gracing period not set correctly");
    }

    function test_createProject_alreadyExists() public {
        vm.prank(alice);
        mintTicket.createTicket(GRACING_PERIOD);
        vm.expectRevert("PROJECT_EXISTS");
        vm.prank(alice);
        mintTicket.createTicket(GRACING_PERIOD);
    }

    function test_createProject_gracingPeriodUnder1() public {
        vm.prank(alice);
        vm.expectRevert("GRACING_UNDER_1");
        mintTicket.createTicket(0);
    }
}

contract MintTicketTestMint is MintTicketTest {
    function test_mint() public {
        vm.prank(alice);
        mintTicket.createTicket(GRACING_PERIOD);
        vm.prank(alice);
        mintTicket.mintTicket(bob, TICKET_PRICE);
        (
            address issuer,
            address owner,
            uint256 createdAt,
            uint256 taxationLocked,
            uint256 taxationStart,
            uint256 price
        ) = mintTicket.userTickets(0);
        assertTrue(owner == bob, "Invalid owner");
        assertTrue(issuer == alice, "Invalid issuer");
        assertTrue(createdAt == block.timestamp, "Invalid createdAt");
        assertTrue(taxationLocked == 0, "Invalid taxationLocked");
        assertTrue(taxationStart == block.timestamp + GRACING_PERIOD * 1 days, "Invalid taxationStart");
        assertTrue(price == TICKET_PRICE, "Invalid price");
    }

    function test_mint_projectDoesNotExist() public {
        vm.prank(alice);
        mintTicket.createTicket(GRACING_PERIOD);
        vm.prank(bob);
        vm.expectRevert("PROJECT_DOES_NOT_EXISTS");
        mintTicket.mintTicket(bob, TICKET_PRICE);
    }

    function test_mint_priceBelowMinPrice() public {
        vm.prank(alice);
        mintTicket.createTicket(GRACING_PERIOD);
        vm.prank(alice);
        mintTicket.mintTicket(bob, 1);
        (
            address issuer,
            address owner,
            uint256 createdAt,
            uint256 taxationLocked,
            uint256 taxationStart,
            uint256 price
        ) = mintTicket.userTickets(0);
        assertTrue(owner == bob, "Invalid owner");
        assertTrue(issuer == alice, "Invalid issuer");
        assertTrue(createdAt == block.timestamp, "Invalid createdAt");
        assertTrue(taxationLocked == 0, "Invalid taxationLocked");
        assertTrue(taxationStart == block.timestamp + GRACING_PERIOD * 1 days, "Invalid taxationStart");
        assertTrue(price == Constants.MINT_TICKET_MIN_PRICE, "Invalid price");
    }
}

contract MintTicketTestUpdatePrice is MintTicketTest {
    function test_updatePrice() public {
        uint256 newPrice = TICKET_PRICE * 2;
        uint256 tax = (newPrice * 14) / 10000;
        uint256 newCoverage = 45;
        uint256 taxAmount = newCoverage * tax;
        vm.prank(alice);
        mintTicket.createTicket(GRACING_PERIOD);
        vm.prank(alice);
        mintTicket.mintTicket(bob, TICKET_PRICE);
        vm.prank(bob);
        mintTicket.updatePrice{value: taxAmount}(0, newPrice, newCoverage);
        (
            address issuer,
            address owner,
            uint256 createdAt,
            uint256 taxationLocked,
            uint256 taxationStart,
            uint256 price
        ) = mintTicket.userTickets(0);
        uint256 daysSinceCreated = (block.timestamp - createdAt) / 1 days;
        uint256 startDay = createdAt + daysSinceCreated * 1 days;
        console.log("%s %s", startDay, taxationStart);
        require(price == newPrice, "Price not updated correctly");
        require(taxationStart == startDay, "taxationStart not updated correctly");
        require(taxationLocked == taxAmount, "TaxationLocked not updated correctly");
    }


}

//
//    function test_updatePrice() public {
//        uint256 tokenId = 0;
//        address minter = address(nonAdmin);
//        uint256 price = 1 ether;
//        uint256 newPrice = 2 ether;
//        uint256 coverage = gracingPeriod + 1; // Set coverage outside the gracing period
//
//        issuer.createProject(gracingPeriod, metadata);
//        issuer.mintTicket(minter, price);
//
//        // Transfer sufficient funds to cover the tax
//        uint256 taxAmount = 1 ether;
//        mintTicket.payTax{value: taxAmount}(tokenId);
//
//        mintTicket.updatePrice(tokenId, newPrice, coverage);
//
//        (address issuerAddress, address minterAddress, uint256 storedPrice) = mintTicket.tokenData(tokenId);
//        assertTrue(minterAddress == minter, "Should revert if the sender is not the owner of the token");
//        assertTrue(storedPrice == newPrice, "Price not updated correctly");
//
//        uint256 distanceFc = distanceForeclosure(price, mintTicket.taxationLocked(tokenId), mintTicket.taxationStart(tokenId), block.timestamp);
//        uint256 minPrice = mintTicket.minPrice();
//        uint256 expectedPrice = foreclosurePrice(price, distanceFc, minPrice);
//        assertTrue(storedPrice == expectedPrice, "Foreclosure price not set correctly");
//
//        (uint256 taxToPayBefore, uint256 taxToReleaseBefore) = taxRelease(price, mintTicket.taxationLocked(tokenId), mintTicket.taxationStart(tokenId), block.timestamp);
//        uint256 dailyTax = dailyTaxAmount(expectedPrice);
//        uint256 expectedTaxationLocked = dailyTax * coverage;
//        assertTrue(mintTicket.taxationLocked(tokenId) == expectedTaxationLocked, "taxationLocked not updated correctly");
//        assertTrue(mintTicket.taxationStart(tokenId) == mintTicket.taxationStart(tokenId), "taxationStart should not be updated");
//    }
//
//    function test_updatePrice_tokenDoesNotExist() public {
//        uint256 tokenId = 0;
//        uint256 newPrice = 2 ether;
//        uint256 coverage = 10;
//
//        assertRevert(
//        function () {
//    mintTicket.updatePrice(tokenId, newPrice, coverage);
//    },
//        "TOKEN_DOES_NOT_EXIST",
//        "Should revert if the token does not exist"
//        );
//    }
//
//    function test_updatePrice_senderNotOwner() public {
//        uint256 tokenId = 0;
//        address minter = address(nonAdmin);
//        uint256 price = 1 ether;
//        uint256 newPrice = 2 ether;
//        uint256 coverage = 10;
//
//        issuer.createProject(gracingPeriod, metadata);
//        issuer.mintTicket(minter, price);
//
//        assertRevert(
//        function () {
//    mintTicket.connect(fxHashAdmin).updatePrice(tokenId, newPrice, coverage);
//    },
//        "INSUFFICIENT_BALANCE",
//        "Should revert if the sender is not the owner of the token"
//        );
//    }
//
//    function test_updatePrice_newPriceBelowMinPrice() public {
//        uint256 tokenId = 0;
//        address minter = address(nonAdmin);
//        uint256 price = 1 ether;
//        uint256 newPrice = 1 wei;
//        uint256 coverage = 10;
//
//        mintTicket.setMinPrice(1 ether);
//        issuer.createProject(gracingPeriod, metadata);
//        issuer.mintTicket(minter, price);
//
//        assertRevert(
//        function () {
//    mintTicket.updatePrice(tokenId, newPrice, coverage);
//    },
//        "PRICE_BELOW_MIN_PRICE",
//        "Should revert if the new price is below the minimum price"
//        );
//    }
//
//    function test_updatePrice_coverageLessThan1() public {
//        uint256 tokenId = 0;
//        address minter = address(nonAdmin);
//        uint256 price = 1 ether;
//        uint256 newPrice = 2 ether;
//        uint256 coverage = 0;
//
//        issuer.createProject(gracingPeriod, metadata);
//        issuer.mintTicket(minter, price);
//
//        assertRevert(
//        function () {
//    mintTicket.updatePrice(tokenId, newPrice, coverage);
//    },
//        "MIN_1_COVERAGE",
//        "Should revert if the coverage is less than 1"
//        );
//    }
//
//    function test_payTax() public {
//        uint256 tokenId = 0;
//        address minter = address(nonAdmin);
//        uint256 price = 1 ether;
//
//        issuer.createProject(gracingPeriod, metadata);
//        issuer.mintTicket(minter, price);
//
//        uint256 taxationLockedBefore = mintTicket.taxationLocked(tokenId);
//        uint256 taxAmount = 0.01 ether;
//
//        mintTicket.payTax{value: taxAmount}(tokenId);
//
//        uint256 taxationLockedAfter = mintTicket.taxationLocked(tokenId);
//        uint256 dailyTax = dailyTaxAmount(price);
//        uint256 daysCoverage = taxAmount / dailyTax;
//        uint256 cleanCoverage = dailyTax * daysCoverage;
//        assertTrue(taxationLockedAfter == taxationLockedBefore + cleanCoverage, "Taxation locked not updated correctly");
//    }
//
//    function test_payTax_tokenDoesNotExist() public {
//        uint256 tokenId = 0;
//        uint256 taxAmount = 0.01 ether;
//
//        assertRevert(
//        function () {
//    mintTicket.payTax{value: taxAmount}(tokenId);
//    },
//        "TOKEN_DOES_NOT_EXIST",
//        "Should revert if the token does not exist"
//        );
//    }
//
//    function test_claim() public {
//        uint256 tokenId = 0;
//        address minter = address(nonAdmin);
//        uint256 price = 1 ether;
//        uint256 coverage = 30;
//        address transferTo = address(admin);
//
//        issuer.createProject(gracingPeriod, metadata);
//        issuer.mintTicket(minter, price);
//
//        // Set taxationStart to a time outside the gracing period
//        uint256 tokenIdBefore = tokenId;
//        uint256 gracingPeriodSeconds = gracingPeriod * 86400;
//        uint256 startDay = mintTicket.tokenData(tokenIdBefore).createdAt + gracingPeriodSeconds + 1;
//        uint256 blockTimestamp = block.timestamp;
//
//        mintTicket.setMinPrice(1 ether);
//        uint256 dailyTax = dailyTaxAmount(price);
//        uint256 taxAmount = dailyTax * coverage;
//        uint256 amountRequired = taxAmount;
//        uint256 transferAmount = amountRequired + 1 ether; // Adjust the transfer amount as needed
//
//        // Advance time to startDay
//        _mockSetTimestamp(startDay);
//
//        uint256 tokenIdBeforeBalance = address(issuer).balance;
//
//        mintTicket.claim{value: transferAmount}(tokenId, price, coverage, transferTo);
//
//        uint256 tokenIdAfterBalance = address(issuer).balance;
//
//        // Validate results
//        assertTrue(mintTicket.ownerOf(tokenId) == transferTo, "Token not claimed correctly");
//        uint256 distanceFc = distanceForeclosure(price, mintTicket.tokenData(tokenIdBefore), startDay);
//        if (distanceFc > 86400) {
//            distanceFc = 86400;
//        }
//        uint256 newPrice = foreclosurePrice(price, distanceFc);
//        assertTrue(mintTicket.tokenData(tokenId).price == newPrice, "Price not updated correctly");
//
//        uint256 expectedTaxationLocked = dailyTaxAmount(newPrice) * coverage;
//        assertTrue(mintTicket.taxationLocked(tokenIdBefore) == expectedTaxationLocked, "Taxation locked not updated correctly");
//        assertTrue(mintTicket.taxationStart(tokenIdBefore) == startDay, "taxationStart should not be updated");
//
//        uint256 actualTaxationLockedDiff = mintTicket.taxationLocked(tokenIdBefore) - mintTicket.taxationLocked(tokenIdBeforeBalance);
//        assertTrue(actualTaxationLockedDiff == taxAmount, "TaxationLocked diff not updated correctly");
//
//        uint256 expectedTaxationLockedAfter = expectedTaxationLocked - taxAmount;
//        assertTrue(mintTicket.taxationLocked(tokenIdBeforeBalance) == expectedTaxationLockedAfter, "TaxationLocked not updated correctly");
//
//        uint256 expectedTaxToPay = dailyTax * coverage;
//        uint256 actualTaxToPay = mintTicket.taxationLocked(tokenIdBeforeBalance) - mintTicket.taxationLocked(tokenIdAfterBalance);
//        assertTrue(actualTaxToPay == expectedTaxToPay, "TaxToPay not calculated correctly");
//    }
//
//    function test_claim_tokenDoesNotExist() public {
//        uint256 tokenId = 0;
//        uint256 price = 1 ether;
//        uint256 coverage = 30;
//        address transferTo = address(admin);
//
//        assertRevert(
//        function () {
//    mintTicket.claim{value: price * coverage}(tokenId, price, coverage, transferTo);
//    },
//        "TOKEN_DOES_NOT_EXIST",
//        "Should revert if the token does not exist"
//        );
//    }
