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
import {MintPassGroup} from "contracts/mint-pass-group/MintPassGroup.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "forge-std/console.sol";

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
        ReserveOptions reserveOption;
        MintTicketOptions mintTicketOption;
    }

    Deploy public deploy;

    uint256 public constant NUMBER = 100;
    uint256 public constant PRICE = 1000;
    uint256 public constant OPEN_DELAY = 60;

    uint256 public mintNb;
    uint256 public time;
    uint256 public lastMint;

    function setUp() public {
        deploy = new Deploy();
        deploy.setUp();
        deploy.run();
    }

    function run() public {
        mintAllGetIssuerCombinations();
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
        vm.startBroadcast(deploy.alice());
        for (uint i = 0; i < uint(ReserveOptions.WhitelistAndMintPass) + 1; i++) {
            for (uint j = 0; j < uint(PricingOptions.DutchAuction) + 1; j++) {
                for (uint k = 0; k < uint(OpenEditionsOptions.Disabled) + 1; k++) {
                    for (uint l = 0; l < uint(MintTicketOptions.Disabled) + 1; l++) {
                        for (uint m = 0; m < uint(OnChainOptions.Disabled) + 1; m++) {
                            MintPassGroup _mintPassGroup;
                            Issuer _issuer = new Issuer(
                                address(deploy.configurationManager()),
                                deploy.alice()
                            );
                            GenTk _genTk = new GenTk(
                                deploy.alice(),
                                address(_issuer),
                                address(deploy.configurationManager())
                            );
                            _issuer.setGenTk(address(_genTk));

                            if (
                                i == uint(ReserveOptions.MintPass) ||
                                i == uint(ReserveOptions.WhitelistAndMintPass)
                            ) {
                                _mintPassGroup = new MintPassGroup(
                                    deploy.MAX_PER_TOKEN(),
                                    deploy.MAX_PER_TOKEN_PER_PROJECT(),
                                    deploy.signer(),
                                    address(deploy.reserveMintPass()),
                                    new address[](0)
                                );
                            }

                            _issuer.mintIssuer(
                                _getMintIssuerInput(
                                    MintIssuerInput({
                                        issuer: address(_issuer),
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
                                issuer: address(_issuer),
                                mintPassGroup: address(_mintPassGroup),
                                recipient: deploy.bob(),
                                referrer: deploy.signer(),
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
        sleep();

        vm.stopBroadcast();
        vm.startBroadcast(deploy.bob());
        for (uint i = 0; i < mintQueue.length; i++) {
            Issuer(mintQueue[i].issuer).mint(_getMintInput(mintQueue[i]));
        }
        vm.stopBroadcast();
    }

    function sleep() public {
        string[] memory runJsInputs = new string[](3);

        // Build ffi command string
        runJsInputs[0] = "node";
        runJsInputs[1] = "script/sleep.js";
        runJsInputs[2] = vm.toString((OPEN_DELAY + 10) * 1000);
        vm.ffi(runJsInputs);
    }

    // Issuer features
    //  - Mint Ticket (True/False)
    //  - Open Editions (True/False)
    //  - Reserves (None/Whitelist/Mint Pass)
    //  - Pricing (Fixed price/Dutch Auction)
    //  - On chain / off chain
    function _getMintInput(
        MintInput memory mintInput
    ) public view returns (IIssuer.MintInput memory) {
        bytes memory inputBytes;
        bytes memory reserveInput;
        bool createTicket = false;
        if (mintInput.reserveOption == ReserveOptions.Whitelist) {
            LibReserve.ReserveData[] memory reserves = new LibReserve.ReserveData[](1);
            ReserveWhitelist.WhitelistEntry[]
                memory whitelistEntries = new ReserveWhitelist.WhitelistEntry[](1);

            whitelistEntries[0] = ReserveWhitelist.WhitelistEntry({
                whitelisted: mintInput.recipient,
                amount: 2
            });

            reserves[0] = LibReserve.ReserveData({
                methodId: 1,
                amount: 1,
                data: abi.encode(whitelistEntries)
            });
            reserveInput = abi.encode(
                LibReserve.ReserveInput({methodId: 1, input: abi.encode(reserves)})
            );
        } else if (mintInput.reserveOption == ReserveOptions.MintPass) {
            LibReserve.ReserveData[] memory reserves = new LibReserve.ReserveData[](1);
            reserves[0] = LibReserve.ReserveData({
                methodId: 2,
                amount: 1,
                data: abi.encode(mintInput.mintPassGroup)
            });
            reserveInput = abi.encode(
                LibReserve.ReserveInput({
                    methodId: 2,
                    input: getMintPassGroupPayload(
                        mintInput.issuer,
                        mintInput.recipient,
                        mintInput.mintPassGroup
                    )
                })
            );
        } else if (mintInput.reserveOption == ReserveOptions.WhitelistAndMintPass) {
            LibReserve.ReserveData[] memory reserves = new LibReserve.ReserveData[](1);
            ReserveWhitelist.WhitelistEntry[]
                memory whitelistEntries = new ReserveWhitelist.WhitelistEntry[](1);

            whitelistEntries[0] = ReserveWhitelist.WhitelistEntry({
                whitelisted: mintInput.recipient,
                amount: 2
            });

            reserves[0] = LibReserve.ReserveData({
                methodId: 1,
                amount: 1,
                data: abi.encode(whitelistEntries)
            });
            reserveInput = abi.encode(
                LibReserve.ReserveInput({methodId: 1, input: abi.encode(reserves)})
            );
        }

        if (mintInput.mintTicketOption == MintTicketOptions.Enabled) {
            createTicket = true;
        }

        return
            IIssuer.MintInput({
                inputBytes: inputBytes,
                referrer: mintInput.referrer,
                reserveInput: reserveInput,
                createTicket: createTicket,
                recipient: mintInput.recipient
            });
    }

    function _getMintIssuerInput(
        MintIssuerInput memory mintIssuerInput
    ) public view returns (IIssuer.MintIssuerInput memory) {
        LibReserve.ReserveData[] memory reserveData;
        LibPricing.PricingData memory pricingData;
        LibIssuer.OpenEditions memory openEditionsData;
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
                codex: LibCodex.CodexInput({
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

    function _getMintPassParam(
        address mintPassGroup
    ) public pure returns (LibReserve.ReserveData[] memory) {
        LibReserve.ReserveData[] memory reserves = new LibReserve.ReserveData[](1);
        reserves[0] = LibReserve.ReserveData({
            methodId: 2,
            amount: 4,
            data: abi.encode(address(mintPassGroup))
        });
        return reserves;
    }

    function _getWhitelistAndMintPassParam(
        address mintPassGroup
    ) public view returns (LibReserve.ReserveData[] memory) {
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
            data: abi.encode(mintPassGroup)
        });
        return reserves;
    }

    function _getFixedPriceParam() public view returns (LibPricing.PricingData memory) {
        return
            LibPricing.PricingData({
                pricingId: 1,
                details: abi.encode(
                    PricingFixed.PriceDetails({price: PRICE, opensAt: block.timestamp + OPEN_DELAY})
                ),
                lockForReserves: false
            });
    }

    function _getDutchAuctionParam() public view returns (LibPricing.PricingData memory) {
        uint256[] memory levels = new uint256[](4);
        levels[0] = PRICE;
        levels[1] = PRICE / 2;
        levels[2] = PRICE / 3;
        levels[3] = PRICE / 4;
        return
            LibPricing.PricingData({
                pricingId: 2,
                details: abi.encode(
                    PricingDutchAuction.PriceDetails({
                        opensAt: block.timestamp + OPEN_DELAY,
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

    function getMintPassGroupDomainSeparator(address mintPassGroup) public view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes("MintPassGroup")),
                    keccak256(bytes("1")),
                    block.chainid,
                    address(mintPassGroup)
                )
            );
    }

    function getMintPassGroupPayload(
        address issuer,
        address recipient,
        address mintPassGroup
    ) public view returns (bytes memory) {
        MintPassGroup.Payload memory payload = MintPassGroup.Payload({
            token: string.concat("token", string(abi.encode(mintNb))),
            project: issuer,
            addr: recipient
        });

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            deploy.SIGNER_PRIVATE_KEY(),
            ECDSA.toTypedDataHash(
                getMintPassGroupDomainSeparator(mintPassGroup),
                keccak256(
                    abi.encode(
                        keccak256("Payload(string token,address project,address addr)"),
                        keccak256(bytes(payload.token)),
                        payload.project,
                        payload.addr
                    )
                )
            )
        );
        return
            abi.encode(
                MintPassGroup.Pass({
                    payload: abi.encode(payload),
                    signature: abi.encodePacked(r, s, v)
                })
            );
    }
}
