// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/extensions/MintPass/MintPassTest.t.sol";

contract ClaimMintPassTest is MintPassTest {
    uint8 internal v;
    bytes32 internal r;
    bytes32 internal s;
    bytes32 internal digest;
    address internal signer;

    function test_SignMintPass() public {
        digest = mintPass.generateTypedDataHash(address(0), 0, 0, claimIndex, claimerAddr);
        (v, r, s) = vm.sign(signerPk, digest);
        signer = ECDSA.recover(digest, v, r, s);
        assertTrue(signer == signerAddr, "Invalid signature");
    }

    function test_SignMintPass_InvalidSignature() public {
        digest = mintPass.generateTypedDataHash(address(0), 0, 0, claimIndex, claimerAddr);
        (v, r, s) = vm.sign(signerPk + 1, digest);
        signer = ECDSA.recover(digest, v, r, s);
        assertFalse(signer == signerAddr, "Signature was valid");
    }

    function test_ClaimMintPass() public {
        digest = mintPass.generateTypedDataHash(address(0), 0, 0, claimIndex, claimerAddr);
        (v, r, s) = vm.sign(signerPk, digest);
        mintPass.claimMintPass(claimIndex, abi.encodePacked(r, s, v));
        assertTrue(mintPass.isClaimed(claimIndex), "Mint pass not claimed");
    }

    function test_ClaimMintPass_RevertsWhen_PassAlreadyClaimed() public {
        digest = mintPass.generateTypedDataHash(address(0), 0, 0, claimIndex, claimerAddr);
        (v, r, s) = vm.sign(signerPk, digest);
        mintPass.claimMintPass(claimIndex, abi.encodePacked(r, s, v));
        vm.expectRevert(PASS_ALREADY_CLAIMED_ERROR);
        mintPass.claimMintPass(claimIndex, abi.encodePacked(v, r, s));
    }

    function test_ClaimMintPass_RevertsWhen_InvalidSignature() public {
        digest = mintPass.generateTypedDataHash(address(0), 0, 0, claimIndex, claimerAddr);
        (v, r, s) = vm.sign(signerPk, digest);
        vm.prank(address(bob));
        vm.expectRevert(INVALID_SIGNATURE_ERROR);
        mintPass.claimMintPass(claimIndex, abi.encodePacked(r, s, v));
    }
}
