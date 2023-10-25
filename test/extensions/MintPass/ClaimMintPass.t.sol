// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/extensions/MintPass/MintPassTest.t.sol";

contract ClaimMintPassTest is MintPassTest {
    function test_SignMintPass() public {
        bytes32 digest = mintPass.generateTypedDataHash(claimIndex, claimerAddr);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        address signer = ECDSA.recover(digest, v, r, s);
        assertTrue(signer == signerAddr, "Invalid Sig");
    }

    function test_SignMintPass_RevertsWhen_SignatureInvalid() public {
        bytes32 digest = mintPass.generateTypedDataHash(claimIndex, claimerAddr);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk + 1, digest);
        address signer = ECDSA.recover(digest, v, r, s);
        assertFalse(signer == signerAddr, "Signature was Valid");
    }

    function test_ClaimMintPass() public {
        bytes32 digest = mintPass.generateTypedDataHash(claimIndex, claimerAddr);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        mintPass.claimMintPass(claimIndex, abi.encodePacked(r, s, v));
        assertTrue(mintPass.isClaimed(claimIndex), "Mint pass not claimed");
    }

    function test_ClaimMintPass_RevertsWhen_AlreadyClaimed() public {
        bytes32 digest = mintPass.generateTypedDataHash(claimIndex, claimerAddr);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        mintPass.claimMintPass(claimIndex, abi.encodePacked(r, s, v));
        assertTrue(mintPass.isClaimed(claimIndex), "Mint pass not claimed");
        vm.expectRevert(PASS_ALREADY_CLAIMED_ERROR);
        mintPass.claimMintPass(claimIndex, abi.encodePacked(v, r, s));
    }

    function test_ClaimMintPass_RevertsWhen_NotClaimer() public {
        bytes32 digest = mintPass.generateTypedDataHash(claimIndex, claimerAddr);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        vm.prank(address(bob));
        vm.expectRevert(INVALID_SIGNATURE_ERROR);
        mintPass.claimMintPass(claimIndex, abi.encodePacked(r, s, v));
        assertTrue(!mintPass.isClaimed(claimIndex), "Mint was claimed");
    }
}
