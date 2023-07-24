// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {IMintTicket} from "contracts/interfaces/IMintTicket.sol";
import {MintTicket} from "contracts/mint-ticket/MintTicket.sol";
import {IIssuer, LibIssuer, LibReserve, LibRoyalty, LibPricing, LibCodex} from "contracts/interfaces/IIssuer.sol";
import {WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";
import {Randomizer} from "contracts/randomizer/Randomizer.sol";
import {Constants} from "script/Constants.sol";
import {Accounts} from "script/Accounts.s.sol";
import {Deploy} from "script/Deploy.s.sol";

contract MintTicketTest is Test, Deploy {
    event TicketCreated(address issuer, uint256 gracingPeriod);
    event TicketMinted(address issuer, address minter, uint256 price);
    event PriceUpdated(uint256 tokenId, uint256 price, uint256 coverage);
    event TaxPayed(uint256 tokenId);
    event TicketClaimed(uint256 tokenId, uint256 price, uint256 coverage, address transferTo);
    event TicketConsumed(address owner, uint256 tokenId, address issuer);

    address public testIssuer;

    // Additional state variables
    uint256 public constant GRACING_PERIOD = 30;
    uint256 public constant TICKET_PRICE = 10000;

    function setUp() public virtual override {
        createAccounts();
        Deploy.setUp();
        Deploy.run();
        (testIssuer, ) = fxHashFactory.createProject(alice);
        IIssuer(testIssuer).mintIssuer(
            IIssuer.MintIssuerInput(
                LibCodex.CodexInput(1, "Test", 0, testIssuer),
                "",
                0,
                1000,
                LibIssuer.OpenEditions(0, ""),
                IIssuer.MintTicketSettings(GRACING_PERIOD, ""),
                new LibReserve.ReserveData[](0),
                LibPricing.PricingData(1, abi.encode(TICKET_PRICE, 1), true),
                LibRoyalty.RoyaltyData(1500, alice),
                LibRoyalty.RoyaltyData(1500, alice),
                true,
                new uint256[](0),
                new WrappedScriptRequest[](0)
            )
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
        assertTrue(
            taxationStart == block.timestamp + GRACING_PERIOD * 1 days,
            "Invalid taxationStart"
        );
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
        assertTrue(
            taxationStart == block.timestamp + GRACING_PERIOD * 1 days,
            "Invalid taxationStart"
        );
        assertTrue(price == Constants.MINT_TICKET_MIN_PRICE, "Invalid price");
    }
}

contract MintTicketTestPayTax is MintTicketTest {
    function test_payTax() public {
        // Calculate the tax amount for the given ticket's price
        uint256 dailyTax = (TICKET_PRICE * 14) / 10000;
        uint256 daysCoverage = 45; // Number of days you want to cover
        uint256 taxAmount = dailyTax * daysCoverage;

        // Send the required amount of Ether with the transaction
        uint256 amountToSend = taxAmount; // Add an extra wei to cover any gas cost

        vm.prank(bob);
        vm.warp(2);
        IIssuer(testIssuer).mint{value: TICKET_PRICE}(
            IIssuer.MintInput("", address(0), "", true, bob)
        );
        vm.prank(bob);
        mintTicket.payTax{value: amountToSend}(0);

        // Assertions
        (address issuer, address owner, uint256 createdAt, uint256 taxationLocked, , ) = mintTicket
            .userTickets(0);
        require(issuer == testIssuer, "Incorrect ticket issuer");
        require(owner == address(bob), "Incorrect ticket owner");
        require(createdAt > 0, "Ticket not created");
        require(taxationLocked == taxAmount, "Tax not paid correctly");
    }

    function test_payTaxNotExist() public {
        vm.expectRevert("USER_TICKET_DOES_NOT_EXIST");
        mintTicket.payTax{value: 1000}(10);
    }
}

contract MintTicketTestUpdatePrice is MintTicketTest {
    function test_updatePrice() public {
        uint256 newPrice = TICKET_PRICE * 2;
        uint256 newCoverage = 45;
        uint256 dailyTax = (newPrice * 14) / 10000;
        uint256 initTimestamp = 2;
        uint256 updateTimestamp = initTimestamp + GRACING_PERIOD * 1 days + 1 days;
        vm.warp(initTimestamp);
        vm.prank(bob);
        IIssuer(testIssuer).mint{value: TICKET_PRICE}(
            IIssuer.MintInput("", address(0), "", true, bob)
        );

        // Increase time to make sure gracing period is over
        vm.warp(updateTimestamp);

        vm.prank(bob);
        mintTicket.payTax{value: dailyTax * newCoverage}(0);
        uint256 initialBalance = address(mintTicket).balance;

        vm.prank(bob);
        mintTicket.updatePrice{value: dailyTax}(0, newPrice, newCoverage);
        (
            address issuer,
            address owner,
            uint256 createdAt,
            uint256 taxationLocked,
            uint256 taxationStart,
            uint256 price
        ) = mintTicket.userTickets(0);

        assertTrue(price == newPrice);
        assertTrue(taxationStart == updateTimestamp);
        assertTrue(taxationLocked == dailyTax * newCoverage);
    }
}
