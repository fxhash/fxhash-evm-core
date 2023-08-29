// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ECDSA} from "openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "test/unit/utils/MintPass/MintPass.t.sol";

contract ClaimMintPassTest is MintPassTest {
    function test_SignMintPass() public {
        bytes32 digest = mintPass.generateTypedDataHash(claimIndex, claimerAddress, "");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        address signer = ECDSA.recover(digest, v, r, s);
        assertTrue(signer == signerAddress, "Invalid Sig");
    }

    function test_RevertsWhen_SignatureInvalid_SignMintPass() public {
        bytes32 digest = mintPass.generateTypedDataHash(claimIndex, claimerAddress, "");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk + 1, digest);
        address signer = ECDSA.recover(digest, v, r, s);
        assertFalse(signer == signerAddress, "Signature was Valid");
    }

    function test_ClaimMintPass() public {
        bytes32 digest = mintPass.generateTypedDataHash(claimIndex, claimerAddress, "");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        mintPass.claimMintPass(claimIndex, "", abi.encode(v, r, s));
        assertTrue(mintPass.isClaimed(claimIndex), "Mint pass not claimed");
    }

    function test_RevertsWhen_AlreadyClaimed_ClaimMintPass() public {
        bytes32 digest = mintPass.generateTypedDataHash(claimIndex, claimerAddress, "");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        mintPass.claimMintPass(claimIndex, "", abi.encode(v, r, s));
        assertTrue(mintPass.isClaimed(claimIndex), "Mint pass not claimed");
        vm.expectRevert(abi.encodeWithSelector(MintPass.AlreadyClaimed.selector));
        mintPass.claimMintPass(claimIndex, "", abi.encode(v, r, s));
    }

    function test_RevertsWhen_NotClaimer_ClaimMintPass() public {
        bytes32 digest = mintPass.generateTypedDataHash(claimIndex, claimerAddress, "");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        vm.prank(address(bob));
        vm.expectRevert(abi.encodeWithSelector(MintPass.InvalidSig.selector));
        mintPass.claimMintPass(claimIndex, "", abi.encode(v, r, s));
        assertTrue(!mintPass.isClaimed(claimIndex), "Mint was claimed");
    }
}
