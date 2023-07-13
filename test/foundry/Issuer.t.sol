// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Deploy} from "script/Deploy.s.sol";
import {IIssuer, LibIssuer, LibReserve, LibRoyalty, LibPricing, LibCodex} from "contracts/interfaces/IIssuer.sol";
import {WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";

contract IssuerTest is Test, Deploy {
    uint256 internal timestamp = 1000;
    uint256 internal price = 1000;

    /// whitelist
    address[] public whitelist;
    uint256[] public allocations;

    /// mint issuer input

    LibCodex.CodexInput public codexInput = LibCodex.CodexInput(1, "Test", 0, address(0));
    bytes public metadata = "metdata";
    uint256 public metadataBytesSize = 256;
    uint256 public amount = 1000;
    LibIssuer.OpenEditions public oe = LibIssuer.OpenEditions(0, "0x");
    IIssuer.MintTicketSettings public mintTicketSettings = IIssuer.MintTicketSettings(0, "0x");
    LibReserve.ReserveData[] public reserveData;
    LibPricing.PricingData public pricing =
        LibPricing.PricingData(1, abi.encode(price, timestamp - 1), true);
    LibRoyalty.RoyaltyData public primary = LibRoyalty.RoyaltyData(1500, alice);
    LibRoyalty.RoyaltyData public royalty = LibRoyalty.RoyaltyData(1000, alice);
    bool public enabled = true;
    uint256[] public tags;
    WrappedScriptRequest[] public onchainScripts;

    function setUp() public override {
        vm.warp(timestamp);
        createAccounts();
        Deploy.run();
        codexInput.issuer = address(issuer);
        whitelist.push(alice);
        whitelist.push(bob);
        whitelist.push(eve);
        allocations.push(10);
        allocations.push(5);
        allocations.push(3);
        reserveData.push(LibReserve.ReserveData(1, 1, abi.encode(whitelist, allocations)));
        tags.push(1);
        tags.push(2);
        tags.push(3);
    }

    function test_MintIssuer() public {
        issuer.mintIssuer(
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
