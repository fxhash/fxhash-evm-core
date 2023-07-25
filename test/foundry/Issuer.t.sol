// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Deploy} from "script/Deploy.s.sol";
import {IIssuer, LibIssuer, LibReserve, LibRoyalty, LibPricing, LibCodex} from "contracts/interfaces/IIssuer.sol";
import {WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";
import {Issuer} from "contracts/issuer/Issuer.sol";
import {GenTk} from "contracts/gentk/GenTk.sol";

contract IssuerTest is Test, Deploy {
    address public scriptIssuer;
    address public scriptGentk;

    uint256 internal timestamp = 1000;
    uint256 internal price = 1000;

    /// whitelist
    address[3] public whitelistFixed = [alice, bob, eve];
    uint256[3] public allocationsFixed = [10, 5, 1];
    uint256[3] public tagsFixed = [1, 2, 3];
    address[] public whitelist;
    uint256[] public allocations;

    LibCodex.CodexInput public codexInput;
    bytes public metadata;
    uint256 public metadataBytesSize;
    uint256 public amount;
    LibIssuer.OpenEditions public oe;
    IIssuer.MintTicketSettings public mintTicketSettings;
    LibReserve.ReserveData[] public reserveData;
    LibPricing.PricingData public pricing;
    LibRoyalty.RoyaltyData public primary;
    LibRoyalty.RoyaltyData public royalty;
    bool public enabled;
    uint256[] public tags;
    WrappedScriptRequest[] public onchainScripts;

    function setUp() public virtual override {
        vm.warp(timestamp);
        createAccounts();
        Deploy.setUp();
        Deploy.run();
        metadata = "metdata";
        metadataBytesSize = 256;
        amount = 1000;
        oe = LibIssuer.OpenEditions(0, "");
        mintTicketSettings = IIssuer.MintTicketSettings(0, "");
        for (uint256 i; i < whitelistFixed.length; i++) whitelist.push(whitelistFixed[i]);
        for (uint256 i; i < allocationsFixed.length; i++) allocations.push(allocationsFixed[i]);
        reserveData.push(LibReserve.ReserveData(1, 1, abi.encode(whitelist, allocations)));
        pricing = LibPricing.PricingData(1, abi.encode(price, timestamp - 1), true);
        primary = LibRoyalty.RoyaltyData(1500, alice);
        royalty = LibRoyalty.RoyaltyData(1000, alice);
        enabled = true;
        for (uint256 i; i < tagsFixed.length; i++) tags.push(tagsFixed[i]);
        /// onchain scripts remains uninitialized
        (scriptIssuer, scriptGentk) = fxHashFactory.createProject(alice);
        codexInput = LibCodex.CodexInput(1, "Test", 0, scriptIssuer);
    }
}

contract MintIssuer is IssuerTest {
    function test_MintIssuer() public {
        IIssuer(scriptIssuer).mintIssuer(
            IIssuer.MintIssuerInput(
                codexInput,
                metadata,
                metadataBytesSize,
                amount,
                oe,
                mintTicketSettings,
                reserveData,
                pricing,
                primary,
                royalty,
                enabled,
                tags,
                onchainScripts
            )
        );
    }
}

contract Mint is IssuerTest {
    IIssuer.MintInput public mintInput;

    function setUp() public virtual override {
        super.setUp();
        metadataBytesSize = 0;
        mintInput = IIssuer.MintInput("", address(0), "", false, alice);
        IIssuer(scriptIssuer).mintIssuer(
            IIssuer.MintIssuerInput(
                codexInput,
                metadata,
                metadataBytesSize,
                amount,
                oe,
                mintTicketSettings,
                reserveData,
                pricing,
                primary,
                royalty,
                enabled,
                tags,
                onchainScripts
            )
        );

        vm.warp(block.timestamp + 1001);
    }

    function test_Mint() public {
        vm.prank(bob);
        IIssuer(scriptIssuer).mint{value: 1000}(mintInput);
    }
}

contract MintWithTicket is IssuerTest {
    IIssuer.MintInput public mintInput;
    IIssuer.MintWithTicketInput public ticketInput;

    function setUp() public virtual override {
        super.setUp();

        mintTicketSettings.gracingPeriod = 1000;
        metadataBytesSize = 0;
        mintInput = IIssuer.MintInput("", address(0), "", true, alice);
        IIssuer(scriptIssuer).mintIssuer(
            IIssuer.MintIssuerInput(
                codexInput,
                metadata,
                metadataBytesSize,
                amount,
                oe,
                mintTicketSettings,
                reserveData,
                pricing,
                primary,
                royalty,
                enabled,
                tags,
                onchainScripts
            )
        );

        vm.warp(block.timestamp + 1001);

        ticketInput = IIssuer.MintWithTicketInput(0, "", address(0));
        vm.prank(alice);
        IIssuer(scriptIssuer).mint{value: 1000}(mintInput);
    }

    function test_MintWithTicket() public {
        vm.prank(alice);
        IIssuer(scriptIssuer).mintWithTicket(ticketInput);
    }
}
