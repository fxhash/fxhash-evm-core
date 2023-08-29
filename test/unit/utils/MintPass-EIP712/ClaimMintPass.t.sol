// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {BaseTest} from "test/BaseTest.t.sol";
import {ECDSA} from "openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MockMintPass} from "test/mocks/MockMintPass-EIP712.sol";

contract MintPass712Test is BaseTest {
    MockMintPass internal mintPass;
    uint256 internal signerPk = 1;
    address internal signerAddress = vm.addr(signerPk);

    function setUp() public override {
        mintPass = new MockMintPass(signerAddress);
    }

    function test_SignMintPass() public {
        bytes32 digest = mintPass.genTypedDataHash(1, address(this), "");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        address signer = ECDSA.recover(digest, v, r, s);
        assertTrue(signer == signerAddress, "Invalid Sig");
    }

    function test_RevertsWhen_SignatureInvalid_SignMintPass() public {
        bytes32 digest = mintPass.genTypedDataHash(1, address(this), "");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk + 1, digest);
        address signer = ECDSA.recover(digest, v, r, s);
        assertFalse(signer == signerAddress, "Signature was Valid");
    }

    function test_ClaimMintPass() public {
        bytes32 digest = mintPass.genTypedDataHash(1, address(this), "");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        mintPass.claimMintPass(1, "", abi.encode(v, r, s));
        assertTrue(mintPass.isClaimed(1), "Mint pass not claimed");
    }

    function test_RevertsWhen_AlreadyClaimed_ClaimMintPass() public {
        bytes32 digest = mintPass.genTypedDataHash(1, address(this), "");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        mintPass.claimMintPass(1, "", abi.encode(v, r, s));
        assertTrue(mintPass.isClaimed(1), "Mint pass not claimed");
        vm.expectRevert();
        mintPass.claimMintPass(1, "", abi.encode(v, r, s));
    }
}
