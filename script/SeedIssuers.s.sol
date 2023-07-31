// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Deploy} from "./Deploy.s.sol";
import {ReserveWhitelist} from "contracts/reserve/ReserveWhitelist.sol";
import {PricingFixed} from "contracts/pricing/PricingFixed.sol";
import {PricingDutchAuction} from "contracts/pricing/PricingDutchAuction.sol";
import {IIssuer, OpenEditions} from "contracts/interfaces/IIssuer.sol";
import {PricingData} from "contracts/interfaces/IPricing.sol";
import {ReserveData} from "contracts/interfaces/IReserve.sol";
import {RoyaltyData} from "contracts/interfaces/ISplitsMain.sol";
import {CodexData, CodexInput} from "contracts/interfaces/ICodex.sol";
import {WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";
import {Issuer} from "contracts/issuer/Issuer.sol";
import {GenTk} from "contracts/gentk/GenTk.sol";
import {MintPassGroup} from "contracts/mint-pass-group/MintPassGroup.sol";
import {Constants} from "script/Constants.sol";

contract SeedIssuers is Deploy {
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

    struct MintIssuerInput {
        address issuer;
        address mintPassGroup;
        ReserveOptions reserveOption;
        PricingOptions pricingOption;
        OpenEditionsOptions openEditionsOption;
        MintTicketOptions mintTicketOption;
        OnChainOptions onChainOption;
    }

    struct MintInput {
        address issuer;
        address mintPassGroup;
        address recipient;
        address referrer;
        address mintTicket;
        ReserveOptions reserveOption;
        MintTicketOptions mintTicketOption;
    }

    uint256 public mintNb;
    uint256 public time;
    uint256 public lastMint;

    string public MNEMONIC = vm.envString("MNEMONIC");
    address payable[] public royaltyReceivers;
    uint96[] public royaltyBasisPoints;

    function setUp() public virtual override {
        //vm.startBroadcast(deployer);
        createAccounts();
        royaltyReceivers.push(payable(alice));
        royaltyBasisPoints.push(1500);
        Deploy.setUp();
        Deploy.run();
        //vm.stopBroadcast();
    }

    function run() public virtual override {
        mintAllGetIssuerCombinations();
    }

    function createAccounts() public override {
        alice = vm.addr(vm.deriveKey(MNEMONIC, 0));
        bob = vm.addr(vm.deriveKey(MNEMONIC, 1));
        eve = vm.addr(vm.deriveKey(MNEMONIC, 2));
        susan = vm.addr(vm.deriveKey(MNEMONIC, 3));

        vm.rememberKey(vm.deriveKey(MNEMONIC, 0));
        vm.rememberKey(vm.deriveKey(MNEMONIC, 1));
        vm.rememberKey(vm.deriveKey(MNEMONIC, 2));
        vm.rememberKey(vm.deriveKey(MNEMONIC, 3));
    }

    function getTotalCombinations() public pure returns (uint256) {
        uint256 reserveOptionsCount = uint256(ReserveOptions.WhitelistAndMintPass) + 1;
        uint256 pricingOptionsCount = uint256(PricingOptions.DutchAuction) + 1;
        uint256 openEditionsOptionsCount = uint256(OpenEditionsOptions.Disabled) + 1;
        uint256 mintTicketOptionsCount = uint256(MintTicketOptions.Disabled) + 1;
        uint256 onChainOptionsCount = uint256(OnChainOptions.Disabled) + 1;

        return
            reserveOptionsCount *
            pricingOptionsCount *
            openEditionsOptionsCount *
            mintTicketOptionsCount *
            onChainOptionsCount;
    }

    function mintAllGetIssuerCombinations() public {
        MintInput[] memory mintQueue = new MintInput[](getTotalCombinations());
        vm.startBroadcast(alice);
        for (uint256 i = 0; i < uint256(ReserveOptions.WhitelistAndMintPass) + 1; i++) {
            for (uint256 j = 0; j < uint256(PricingOptions.DutchAuction) + 1; j++) {
                for (uint256 k = 0; k < uint256(OpenEditionsOptions.Disabled) + 1; k++) {
                    for (uint256 l = 0; l < uint256(MintTicketOptions.Disabled) + 1; l++) {
                        for (uint256 m = 0; m < uint256(OnChainOptions.Disabled) + 1; m++) {
                            MintPassGroup _mintPassGroup;
                            (address _issuer, address _genTk) = fxHashFactory.createProject(
                                royaltyReceivers,
                                royaltyBasisPoints,
                                alice
                            );

                            if (
                                i == uint256(ReserveOptions.MintPass) ||
                                i == uint256(ReserveOptions.WhitelistAndMintPass)
                            ) {
                                _mintPassGroup = new MintPassGroup(
                                    Constants.MAX_PER_TOKEN,
                                    Constants.MAX_PER_TOKEN_PER_PROJECT,
                                    vm.addr(vm.envUint("SIGNER_PRIVATE_KEY")),
                                    address(reserveMintPass),
                                    new address[](0)
                                );
                            }

                            IIssuer(_issuer).mintIssuer(
                                _getMintIssuerInput(
                                    MintIssuerInput({
                                        issuer: _issuer,
                                        mintPassGroup: address(_mintPassGroup),
                                        reserveOption: ReserveOptions(i),
                                        pricingOption: PricingOptions(j),
                                        openEditionsOption: OpenEditionsOptions(k),
                                        mintTicketOption: MintTicketOptions(l),
                                        onChainOption: OnChainOptions(m)
                                    })
                                )
                            );

                            mintQueue[mintNb] = MintInput({
                                issuer: _issuer,
                                mintPassGroup: address(_mintPassGroup),
                                recipient: bob,
                                referrer: eve,
                                mintTicket: address(mintTicket),
                                reserveOption: ReserveOptions(i),
                                mintTicketOption: MintTicketOptions(l)
                            });
                            mintNb++;
                            lastMint = block.timestamp;
                        }
                    }
                }
            }
        }
        vm.stopBroadcast();
        vm.writeJson(
            vm.serializeBytes("issuers", "issuersData", abi.encode(mintQueue)),
            "script/issuers.json"
        );
    }

    function sleep() public {
        string[] memory runJsInputs = new string[](3);

        // Build ffi command string
        runJsInputs[0] = "node";
        runJsInputs[1] = "script/sleep.js";
        runJsInputs[2] = vm.toString((Constants.OPEN_DELAY + 10) * 1000);
        vm.ffi(runJsInputs);
    }

    // Issuer features
    //  - Mint Ticket (True/False)
    //  - Open Editions (True/False)
    //  - Reserves (None/Whitelist/Mint Pass)
    //  - Pricing (Fixed price/Dutch Auction)
    //  - On chain / off chain
    function _getMintIssuerInput(
        MintIssuerInput memory mintIssuerInput
    ) public view returns (IIssuer.MintIssuerInput memory) {
        ReserveData[] memory reserveData;
        PricingData memory pricingData;
        OpenEditions memory openEditionsData;
        IIssuer.MintTicketSettings memory mintTicketData;
        WrappedScriptRequest[] memory onChainData;

        if (mintIssuerInput.reserveOption == ReserveOptions.None) {
            reserveData = _getEmptyReserveParam();
        } else if (mintIssuerInput.reserveOption == ReserveOptions.Whitelist) {
            reserveData = _getWhitelistParam();
        } else if (mintIssuerInput.reserveOption == ReserveOptions.MintPass) {
            reserveData = _getMintPassParam(mintIssuerInput.mintPassGroup);
        } else if (mintIssuerInput.reserveOption == ReserveOptions.WhitelistAndMintPass) {
            reserveData = _getWhitelistAndMintPassParam(mintIssuerInput.mintPassGroup);
        }

        if (mintIssuerInput.pricingOption == PricingOptions.Fixed) {
            pricingData = _getFixedPriceParam();
        } else {
            pricingData = _getDutchAuctionParam();
        }

        if (mintIssuerInput.openEditionsOption == OpenEditionsOptions.Enabled) {
            openEditionsData = _getOpenEditionParam();
        } else {
            openEditionsData = _getEmptyOpenEditionParam();
        }

        if (mintIssuerInput.mintTicketOption == MintTicketOptions.Enabled) {
            mintTicketData = _getMintTicketParam();
        } else {
            mintTicketData = _getEmptyMintTicketParam();
        }

        if (mintIssuerInput.onChainOption == OnChainOptions.Enabled) {
            onChainData = _getOnChainScripts();
        } else {
            onChainData = _getEmptyOnChainScripts();
        }
        return
            IIssuer.MintIssuerInput({
                codex: CodexInput({
                    inputType: 0,
                    value: bytes(""),
                    codexId: 0,
                    issuer: mintIssuerInput.issuer
                }),
                metadata: bytes(""),
                inputBytesSize: 0,
                amount: 10,
                openEditions: openEditionsData,
                mintTicketSettings: mintTicketData,
                reserves: reserveData,
                pricing: pricingData,
                primarySplit: _getSplit(),
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

    function _getOpenEditionParam() public view returns (OpenEditions memory) {
        return OpenEditions({closingTime: block.timestamp + 200000000, extra: bytes("")});
    }

    function _getEmptyOpenEditionParam() public pure returns (OpenEditions memory) {
        return OpenEditions({closingTime: 0, extra: bytes("")});
    }

    function _getEmptyReserveParam() public pure returns (ReserveData[] memory) {
        return new ReserveData[](0);
    }

    function _getWhitelistParam() public view returns (ReserveData[] memory) {
        ReserveData[] memory reserves = new ReserveData[](1);
        ReserveWhitelist.WhitelistEntry[]
            memory whitelistEntries = new ReserveWhitelist.WhitelistEntry[](3);

        whitelistEntries[0] = ReserveWhitelist.WhitelistEntry({whitelisted: bob, amount: 2});
        whitelistEntries[1] = ReserveWhitelist.WhitelistEntry({whitelisted: eve, amount: 1});
        whitelistEntries[2] = ReserveWhitelist.WhitelistEntry({whitelisted: susan, amount: 1});

        reserves[0] = ReserveData({methodId: 1, amount: 4, data: abi.encode(whitelistEntries)});
        return reserves;
    }

    function _getMintPassParam(address mintPassGroup) public pure returns (ReserveData[] memory) {
        ReserveData[] memory reserves = new ReserveData[](1);
        reserves[0] = ReserveData({
            methodId: 2,
            amount: 4,
            data: abi.encode(address(mintPassGroup))
        });
        return reserves;
    }

    function _getWhitelistAndMintPassParam(
        address mintPassGroup
    ) public view returns (ReserveData[] memory) {
        ReserveData[] memory reserves = new ReserveData[](2);
        ReserveWhitelist.WhitelistEntry[]
            memory whitelistEntries = new ReserveWhitelist.WhitelistEntry[](3);

        whitelistEntries[0] = ReserveWhitelist.WhitelistEntry({whitelisted: bob, amount: 2});
        whitelistEntries[1] = ReserveWhitelist.WhitelistEntry({whitelisted: eve, amount: 1});
        whitelistEntries[2] = ReserveWhitelist.WhitelistEntry({whitelisted: susan, amount: 1});

        reserves[0] = ReserveData({methodId: 1, amount: 4, data: abi.encode(whitelistEntries)});
        reserves[1] = ReserveData({methodId: 2, amount: 4, data: abi.encode(mintPassGroup)});
        return reserves;
    }

    function _getFixedPriceParam() public view returns (PricingData memory) {
        return
            PricingData({
                pricingId: 1,
                details: abi.encode(
                    PricingFixed.PriceDetails({
                        price: Constants.PRICE,
                        opensAt: block.timestamp + Constants.OPEN_DELAY
                    })
                ),
                lockForReserves: false
            });
    }

    function _getDutchAuctionParam() public view returns (PricingData memory) {
        uint256[] memory levels = new uint256[](4);
        levels[0] = Constants.PRICE;
        levels[1] = Constants.PRICE / 2;
        levels[2] = Constants.PRICE / 3;
        levels[3] = Constants.PRICE / 4;
        return
            PricingData({
                pricingId: 2,
                details: abi.encode(
                    PricingDutchAuction.PriceDetails({
                        opensAt: block.timestamp + Constants.OPEN_DELAY,
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
            contractAddress: address(scriptyStorage),
            contractData: emptyBytes,
            wrapType: 0,
            wrapPrefix: emptyBytes,
            wrapSuffix: emptyBytes,
            scriptContent: emptyBytes
        });

        scriptRequests[1] = WrappedScriptRequest({
            name: "gunzipScripts-0.0.1",
            contractAddress: address(scriptyStorage),
            contractData: emptyBytes,
            wrapType: 0,
            wrapPrefix: emptyBytes,
            wrapSuffix: emptyBytes,
            scriptContent: emptyBytes
        });

        scriptRequests[2] = WrappedScriptRequest({
            name: "fxhash-snippet.js.gz",
            contractAddress: address(scriptyStorage),
            contractData: emptyBytes,
            wrapType: 2,
            wrapPrefix: emptyBytes,
            wrapSuffix: emptyBytes,
            scriptContent: emptyBytes
        });

        scriptRequests[3] = WrappedScriptRequest({
            name: "monad-1960-js.js.gz",
            contractAddress: address(scriptyStorage),
            contractData: emptyBytes,
            wrapType: 2,
            wrapPrefix: emptyBytes,
            wrapSuffix: emptyBytes,
            scriptContent: emptyBytes
        });

        return scriptRequests;
    }

    function _getSplit() public view returns (RoyaltyData memory) {
        return RoyaltyData({percent: 1000, receiver: msg.sender});
    }
}
