// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Deploy} from "./Deploy.s.sol";
import {ReserveWhitelist} from "contracts/reserve/ReserveWhitelist.sol";
import {PricingFixed} from "contracts/pricing/PricingFixed.sol";
import {PricingDutchAuction} from "contracts/pricing/PricingDutchAuction.sol";
import {IIssuer} from "contracts/interfaces/IIssuer.sol";
import {LibReserve} from "contracts/libs/LibReserve.sol";
import {LibPricing} from "contracts/libs/LibPricing.sol";
import {LibRoyalty} from "contracts/libs/LibRoyalty.sol";
import {LibIssuer} from "contracts/libs/LibIssuer.sol";
import {LibCodex} from "contracts/libs/LibCodex.sol";
import {WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";

contract Seed is Script {

    enum ReserveOptions { None, Whitelist, MintPass, WhitelistAndMintPass }
    enum PricingOptions { Fixed, DutchAuction }
    enum OpenEditions { Enabled, Disabled }
    enum MintTicket { Enabled, Disabled }

    Deploy public deploy;

    uint256 public constant NUMBER = 100;

    function setUp() public {
        deploy = new Deploy();
    }

    function run() public {
        vm.startBroadcast();

        deploy.run();

        vm.stopBroadcast();
    }

    // Issuer features
    //  - Mint Ticket (True/False)
    //  - Open Editions (True/False)
    //  - Reserves (None/Whitelist/Mint Pass)
    //  - Pricing (Fixed price/Dutch Auction)
    //  - On chain / off chain

    function getEmptyMintTicketParam() public {
        return IIssuer.MintTicketSettings({
            gracingPeriod: 0,
            metadata: ""
        });
    }

    function getMintTicketParam() public {
        return IIssuer.MintTicketSettings({
            gracingPeriod: 1000,
            metadata: "ipfs://1234"
        });
    }

    function getOpenEditionParam() public {
        return LibIssuer.OpenEditions({
            gracingPeriod: block.timestamp + 1000,
            extra: bytes()
        });
    }

    function getEmptyOpenEditionParam() public {
        return LibIssuer.OpenEditions({
            gracingPeriod: 0,
            extra: bytes()
        });
    }

    function getEmptyReserveParam() public {
        return new LibReserve.ReserveData[](0);
    }

    function getWhitelistParam() public {
        LibReserve.ReserveData[] memory reserves = new LibReserve.ReserveData[](1);
        ReserveWhitelist.WhitelistEntry[] memory whitelistEntries = new ReserveWhitelist.WhitelistEntry[](3);

        whitelistEntries[0] = ReserveWhitelist.WhitelistEntry({
            whitelisted: Deploy.bob(),
            amount: 2
        });
        whitelistEntries[1] = ReserveWhitelist.WhitelistEntry({
            whitelisted: Deploy.eve(),
            amount: 1
        });
        whitelistEntries[1] = ReserveWhitelist.WhitelistEntry({
            whitelisted: Deploy.susan(),
            amount: 1
        });

        reserves[0] = LibReserve.ReserveData({
            methodId: 1,
            amount: 4,
            data: abi.encode(whitelistEntries)
        });
        return reserves;
    }

    function getMintPassParam() public {
        LibReserve.ReserveData[] memory reserves = new LibReserve.ReserveData[](1);
        reserves[0] = LibReserve.ReserveData({
            methodId: 2,
            amount: 4,
            data: abi.encode(Deploy.mintPassGroup())
        });
        return reserves;
    }

    function getWhitelistAndMintPassParam() public {
        LibReserve.ReserveData[] memory reserves = new LibReserve.ReserveData[](2);
        ReserveWhitelist.WhitelistEntry[] memory whitelistEntries = new ReserveWhitelist.WhitelistEntry[](3);

        whitelistEntries[0] = ReserveWhitelist.WhitelistEntry({
            whitelisted: Deploy.bob(),
            amount: 2
        });
        whitelistEntries[1] = ReserveWhitelist.WhitelistEntry({
            whitelisted: Deploy.eve(),
            amount: 1
        });
        whitelistEntries[1] = ReserveWhitelist.WhitelistEntry({
            whitelisted: Deploy.susan(),
            amount: 1
        });

        reserves[0] = LibReserve.ReserveData({
            methodId: 1,
            amount: 4,
            data: abi.encode(whitelistEntries)
        });
        reserves[1] = LibReserve.ReserveData({
            methodId: 2,
            amount: 4,
            data: abi.encode(Deploy.mintPassGroup())
        });
        return reserves;
    }

    function getFixedPriceParam() public {
        return LibPricing.PricingData({
            pricingId: 1,
            details: abi.encode(PricingFixed.PriceDetails({
                price: 1000,
                opensAt: block.timestamp
            })),
            lockForReserves: false
        });
    }

    function getDutchAuctionParam() public {
        return LibPricing.PricingData({
            pricingId: 1,
            details: abi.encode(
                PricingDutchAuction.PriceDetails({
                    opensAt: block.timestamp,
                    decrementDuration: 600,
                    lockedPrice: 0,
                    levels: [1000, 500, 400, 300]
                })
            ),
            lockForReserves: false
        });
    }

    function getEmptyOnChainScripts() public {
        return new WrappedScriptRequest[](0);
    }

    function getOnChainScripts() public {
        WrappedScriptRequest[] scripts = new WrappedScriptRequest[](4);
        bytes memory emptyBytes = "";
        scriptRequests[0] = WrappedScriptRequest({
            name: "monad-1960-bundle.js",
            contractAddress: _contractAddress,
            contractData: emptyBytes,
            wrapType: 0,
            wrapPrefix: emptyBytes,
            wrapSuffix: emptyBytes,
            scriptContent: emptyBytes
        });

        scriptRequests[1] = WrappedScriptRequest({
            name: "gunzipScripts-0.0.1",
            contractAddress: _contractAddress,
            contractData: emptyBytes,
            wrapType: 0,
            wrapPrefix: emptyBytes,
            wrapSuffix: emptyBytes,
            scriptContent: emptyBytes
        });

        scriptRequests[2] = WrappedScriptRequest({
            name: "fxhash-snippet.js.gz",
            contractAddress: _contractAddress,
            contractData: emptyBytes,
            wrapType: 2,
            wrapPrefix: emptyBytes,
            wrapSuffix: emptyBytes,
            scriptContent: emptyBytes
        });

        scriptRequests[3] = WrappedScriptRequest({
            name: "monad-1960-js.js.gz",
            contractAddress: _contractAddress,
            contractData: emptyBytes,
            wrapType: 2,
            wrapPrefix: emptyBytes,
            wrapSuffix: emptyBytes,
            scriptContent: emptyBytes
        });

        return scriptRequests;
    }

    function getSplit() public {
        return LibRoyalty.RoyaltyData({
            percent: 1000,
            receiver: Deploy.alice()
        });
    }
}
