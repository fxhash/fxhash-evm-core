// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Deploy} from "script/Deploy.s.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {GenTk} from "contracts/issuer/GenTk.sol";
import {IIssuer, MintInput} from "contracts/interfaces/IIssuer.sol";
import {MintPassGroup} from "contracts/reserves/MintPassGroup.sol";
import {MintTicket} from "contracts/reserves/MintTicket.sol";
import {PricingContract} from "contracts/interfaces/IPricing.sol";
import {PricingFixed} from "contracts/pricing/PricingFixed.sol";
import {PricingDutchAuction} from "contracts/pricing/PricingDutchAuction.sol";
import {ReserveData, ReserveInput} from "contracts/interfaces/IReserve.sol";
import {ReserveWhitelist} from "contracts/reserves/ReserveWhitelist.sol";
import {RoyaltyData} from "contracts/interfaces/IRoyalties.sol";
import {Script} from "forge-std/Script.sol";
import {SeedIssuers} from "script/seeds/SeedIssuers.s.sol";
import {WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";

contract SeedTokens is Script {
    address public bob;

    string public MNEMONIC = vm.envString("MNEMONIC");

    function setUp() public {
        bob = vm.addr(vm.deriveKey(MNEMONIC, 1));
        vm.rememberKey(vm.deriveKey(MNEMONIC, 1));
    }

    function run() public {
        setUp();
        mintAllTokens();
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
            token: "token",
            project: issuer,
            addr: recipient
        });

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            vm.envUint("SIGNER_PRIVATE_KEY"),
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

    function _getMintInput(
        SeedIssuers.MintInputStruct memory mintInput
    ) public view returns (MintInput memory) {
        bytes memory inputBytes;
        bytes memory reserveInput;
        bool createTicket = false;
        if (mintInput.reserveOption == SeedIssuers.ReserveOptions.Whitelist) {
            ReserveData[] memory reserves = new ReserveData[](1);
            ReserveWhitelist.WhitelistEntry[]
                memory whitelistEntries = new ReserveWhitelist.WhitelistEntry[](1);

            whitelistEntries[0] = ReserveWhitelist.WhitelistEntry({
                whitelisted: mintInput.recipient,
                amount: 2
            });

            reserves[0] = ReserveData({methodId: 1, amount: 1, data: abi.encode(whitelistEntries)});
            reserveInput = abi.encode(ReserveInput({methodId: 1, input: abi.encode(reserves)}));
        } else if (mintInput.reserveOption == SeedIssuers.ReserveOptions.MintPass) {
            ReserveData[] memory reserves = new ReserveData[](1);
            reserves[0] = ReserveData({
                methodId: 2,
                amount: 1,
                data: abi.encode(mintInput.mintPassGroup)
            });
            reserveInput = abi.encode(
                ReserveInput({
                    methodId: 2,
                    input: getMintPassGroupPayload(
                        mintInput.issuer,
                        mintInput.recipient,
                        mintInput.mintPassGroup
                    )
                })
            );
        } else if (mintInput.reserveOption == SeedIssuers.ReserveOptions.WhitelistAndMintPass) {
            ReserveData[] memory reserves = new ReserveData[](1);
            ReserveWhitelist.WhitelistEntry[]
                memory whitelistEntries = new ReserveWhitelist.WhitelistEntry[](1);

            whitelistEntries[0] = ReserveWhitelist.WhitelistEntry({
                whitelisted: mintInput.recipient,
                amount: 2
            });

            reserves[0] = ReserveData({methodId: 1, amount: 1, data: abi.encode(whitelistEntries)});
            reserveInput = abi.encode(ReserveInput({methodId: 1, input: abi.encode(reserves)}));
        }

        if (mintInput.mintTicketOption == SeedIssuers.MintTicketOptions.Enabled) {
            createTicket = true;
        }

        return
            MintInput({
                inputBytes: inputBytes,
                referrer: mintInput.referrer,
                reserveInput: reserveInput,
                createTicket: createTicket,
                recipient: mintInput.recipient
            });
    }

    function loadIssuersJSON() public returns (SeedIssuers.MintInputStruct[] memory) {
        bytes memory data = vm.parseJsonBytes(vm.readFile("script/issuers.json"), ".issuersData");
        return abi.decode(data, (SeedIssuers.MintInputStruct[]));
    }

    function mintAllTokens() public {
        SeedIssuers.MintInputStruct[] memory mintQueue = loadIssuersJSON();
        vm.startBroadcast(bob);
        for (uint i = 0; i < mintQueue.length; i++) {
            IIssuer(mintQueue[i].issuer).mint{value: 1000}(_getMintInput(mintQueue[i]));
            if (mintQueue[i].mintTicketOption == SeedIssuers.MintTicketOptions.Enabled) {
                MintTicket(payable(mintQueue[i].mintTicket)).consume(
                    bob,
                    MintTicket(payable(mintQueue[i].mintTicket)).lastTokenId() - 1,
                    mintQueue[i].issuer
                );
            }
        }
        vm.stopBroadcast();
    }
}
