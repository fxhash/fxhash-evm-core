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
import {Issuer} from "contracts/issuer/Issuer.sol";
import {GenTk} from "contracts/gentk/GenTk.sol";

contract Seed is Script {
    enum ReserveOptions {
        None,
        Whitelist,
        MintPass,
        WhitelistAndMintPass
    }
    enum PricingOptions {
        Fixed,
        DutchAuction
    }
    enum OpenEditionsOptions {
        Enabled,
        Disabled
    }
    enum MintTicketOptions {
        Enabled,
        Disabled
    }
    enum OnChainOptions {
        Enabled,
        Disabled
    }

    Deploy public deploy;

    uint256 public constant NUMBER = 100;
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address account = vm.addr(deployerPrivateKey);

    function setUp() public {
        deploy = new Deploy();
        deploy.setUp();
        deploy.run();
    }

    function run() public {
        vm.startBroadcast(account);
        mintAllGetIssuerCombinations();
        vm.stopBroadcast();
    }

    function mintAllGetIssuerCombinations() public {
        for (uint i = 0; i < uint(ReserveOptions.WhitelistAndMintPass) + 1; i++) {
            for (uint j = 0; j < uint(PricingOptions.DutchAuction) + 1; j++) {
                for (uint k = 0; k < uint(OpenEditionsOptions.Disabled) + 1; k++) {
                    for (uint l = 0; l < uint(MintTicketOptions.Disabled) + 1; l++) {
                        for (uint m = 0; m < uint(OnChainOptions.Disabled) + 1; m++) {

                            Issuer _issuer = new Issuer(
                                address(deploy.configurationManager()),
                                account
                            );
                            GenTk _genTk = new GenTk(
                                account,
                                address(_issuer),
                                address(deploy.configurationManager())
                            );
                            _issuer.setGenTk(address(_genTk));

                            _issuer.mintIssuer(
                                _getIssuerInput(
                                    address(_issuer),
                                    ReserveOptions(i),
                                    PricingOptions(j),
                                    OpenEditionsOptions(k),
                                    MintTicketOptions(l),
                                    OnChainOptions(m)
                                )
                            );
                        }
                    }
                }
            }
        }
    }

    // Issuer features
    //  - Mint Ticket (True/False)
    //  - Open Editions (True/False)
    //  - Reserves (None/Whitelist/Mint Pass)
    //  - Pricing (Fixed price/Dutch Auction)
    //  - On chain / off chain
    function _getIssuerInput(
        address issuer,
        ReserveOptions reserveOption,
        PricingOptions pricingOption,
        OpenEditionsOptions openEditionOption,
        MintTicketOptions mintTicketOptions,
        OnChainOptions onChainOptions
    ) public view returns (IIssuer.MintIssuerInput memory) {
        LibReserve.ReserveData[] memory reserveData;
        LibPricing.PricingData memory pricingData;
        LibIssuer.OpenEditions memory openEditionsData;
        IIssuer.MintTicketSettings memory mintTicketData;
        WrappedScriptRequest[] memory onChainData;

        if (reserveOption == ReserveOptions.None) {
            reserveData = _getEmptyReserveParam();
        } else if (reserveOption == ReserveOptions.Whitelist) {
            reserveData = _getWhitelistParam();
        } else if (reserveOption == ReserveOptions.MintPass) {
            reserveData = _getMintPassParam();
        } else if (reserveOption == ReserveOptions.WhitelistAndMintPass) {
            reserveData = _getWhitelistAndMintPassParam();
        }

        if (pricingOption == PricingOptions.Fixed) {
            pricingData = _getFixedPriceParam();
        } else {
            pricingData = _getDutchAuctionParam();
        }

        if (openEditionOption == OpenEditionsOptions.Enabled) {
            openEditionsData = _getOpenEditionParam();
        } else {
            openEditionsData = _getEmptyOpenEditionParam();
        }

        if (mintTicketOptions == MintTicketOptions.Enabled) {
            mintTicketData = _getMintTicketParam();
        } else {
            mintTicketData = _getEmptyMintTicketParam();
        }

        if (onChainOptions == OnChainOptions.Enabled) {
            onChainData = _getOnChainScripts();
        } else {
            onChainData = _getEmptyOnChainScripts();
        }
        return
            IIssuer.MintIssuerInput({
                codex: LibCodex.CodexInput({
                    inputType: 0,
                    value: bytes(""),
                    codexId: 0,
                    issuer: issuer
                }),
                metadata: bytes(""),
                inputBytesSize: 0,
                amount: 10,
                openEditions: openEditionsData,
                mintTicketSettings: mintTicketData,
                reserves: reserveData,
                pricing: pricingData,
                primarySplit: _getSplit(),
                royaltiesSplit: _getSplit(),
                enabled: true,
                tags: new uint256[](0),
                onChainScripts: onChainData
            });
    }

    function _getEmptyMintTicketParam() public pure returns (IIssuer.MintTicketSettings memory) {
        return IIssuer.MintTicketSettings({gracingPeriod: 0, metadata: ""});
    }

    function _getMintTicketParam() public pure returns (IIssuer.MintTicketSettings memory) {
        return IIssuer.MintTicketSettings({gracingPeriod: 1000, metadata: "ipfs://1234"});
    }

    function _getOpenEditionParam() public view returns (LibIssuer.OpenEditions memory) {
        return LibIssuer.OpenEditions({closingTime: block.timestamp + 2000, extra: bytes("")});
    }

    function _getEmptyOpenEditionParam() public pure returns (LibIssuer.OpenEditions memory) {
        return LibIssuer.OpenEditions({closingTime: 0, extra: bytes("")});
    }

    function _getEmptyReserveParam() public pure returns (LibReserve.ReserveData[] memory) {
        return new LibReserve.ReserveData[](0);
    }

    function _getWhitelistParam() public view returns (LibReserve.ReserveData[] memory) {
        LibReserve.ReserveData[] memory reserves = new LibReserve.ReserveData[](1);
        ReserveWhitelist.WhitelistEntry[]
            memory whitelistEntries = new ReserveWhitelist.WhitelistEntry[](3);

        whitelistEntries[0] = ReserveWhitelist.WhitelistEntry({
            whitelisted: deploy.bob(),
            amount: 2
        });
        whitelistEntries[1] = ReserveWhitelist.WhitelistEntry({
            whitelisted: deploy.eve(),
            amount: 1
        });
        whitelistEntries[2] = ReserveWhitelist.WhitelistEntry({
            whitelisted: deploy.susan(),
            amount: 1
        });

        reserves[0] = LibReserve.ReserveData({
            methodId: 1,
            amount: 4,
            data: abi.encode(whitelistEntries)
        });
        return reserves;
    }

    function _getMintPassParam() public view returns (LibReserve.ReserveData[] memory) {
        LibReserve.ReserveData[] memory reserves = new LibReserve.ReserveData[](1);
        reserves[0] = LibReserve.ReserveData({
            methodId: 2,
            amount: 4,
            data: abi.encode(deploy.mintPassGroup())
        });
        return reserves;
    }

    function _getWhitelistAndMintPassParam() public view returns (LibReserve.ReserveData[] memory) {
        LibReserve.ReserveData[] memory reserves = new LibReserve.ReserveData[](2);
        ReserveWhitelist.WhitelistEntry[]
            memory whitelistEntries = new ReserveWhitelist.WhitelistEntry[](3);

        whitelistEntries[0] = ReserveWhitelist.WhitelistEntry({
            whitelisted: deploy.bob(),
            amount: 2
        });
        whitelistEntries[1] = ReserveWhitelist.WhitelistEntry({
            whitelisted: deploy.eve(),
            amount: 1
        });
        whitelistEntries[2] = ReserveWhitelist.WhitelistEntry({
            whitelisted: deploy.susan(),
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
            data: abi.encode(deploy.mintPassGroup())
        });
        return reserves;
    }

    function _getFixedPriceParam() public view returns (LibPricing.PricingData memory) {
        return
            LibPricing.PricingData({
                pricingId: 1,
                details: abi.encode(
                    PricingFixed.PriceDetails({price: 1000, opensAt: block.timestamp})
                ),
                lockForReserves: false
            });
    }

    function _getDutchAuctionParam() public view returns (LibPricing.PricingData memory) {
        uint256[] memory levels = new uint256[](4);
        levels[0] = 1000;
        levels[1] = 500;
        levels[2] = 400;
        levels[3] = 300;
        return
            LibPricing.PricingData({
                pricingId: 1,
                details: abi.encode(
                    PricingDutchAuction.PriceDetails({
                        opensAt: block.timestamp,
                        decrementDuration: 600,
                        lockedPrice: 0,
                        levels: levels
                    })
                ),
                lockForReserves: false
            });
    }

    function _getEmptyOnChainScripts() public pure returns (WrappedScriptRequest[] memory) {
        return new WrappedScriptRequest[](0);
    }

    function _getOnChainScripts() public view returns (WrappedScriptRequest[] memory) {
        WrappedScriptRequest[] memory scriptRequests = new WrappedScriptRequest[](4);
        bytes memory emptyBytes = "";
        scriptRequests[0] = WrappedScriptRequest({
            name: "monad-1960-bundle.js",
            contractAddress: address(deploy.scriptyStorage()),
            contractData: emptyBytes,
            wrapType: 0,
            wrapPrefix: emptyBytes,
            wrapSuffix: emptyBytes,
            scriptContent: emptyBytes
        });

        scriptRequests[1] = WrappedScriptRequest({
            name: "gunzipScripts-0.0.1",
            contractAddress: address(deploy.scriptyStorage()),
            contractData: emptyBytes,
            wrapType: 0,
            wrapPrefix: emptyBytes,
            wrapSuffix: emptyBytes,
            scriptContent: emptyBytes
        });

        scriptRequests[2] = WrappedScriptRequest({
            name: "fxhash-snippet.js.gz",
            contractAddress: address(deploy.scriptyStorage()),
            contractData: emptyBytes,
            wrapType: 2,
            wrapPrefix: emptyBytes,
            wrapSuffix: emptyBytes,
            scriptContent: emptyBytes
        });

        scriptRequests[3] = WrappedScriptRequest({
            name: "monad-1960-js.js.gz",
            contractAddress: address(deploy.scriptyStorage()),
            contractData: emptyBytes,
            wrapType: 2,
            wrapPrefix: emptyBytes,
            wrapSuffix: emptyBytes,
            scriptContent: emptyBytes
        });

        return scriptRequests;
    }

    function _getSplit() public view returns (LibRoyalty.RoyaltyData memory) {
        return LibRoyalty.RoyaltyData({percent: 1000, receiver: msg.sender});
    }
}
