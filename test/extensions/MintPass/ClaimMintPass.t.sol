// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/extensions/MintPass/MintPass.t.sol";

contract ClaimMintPassTest is MintPassTest {
    function test_SignMintPass() public {
        bytes32 digest = mintPass.generateTypedDataHash(claimIndex, claimerAddr, "");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        address signer = ECDSA.recover(digest, v, r, s);
        assertTrue(signer == signerAddr, "Invalid Sig");
    }

    function test_RevertsWhen_SignatureInvalid_SignMintPass() public {
        bytes32 digest = mintPass.generateTypedDataHash(claimIndex, claimerAddr, "");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk + 1, digest);
        address signer = ECDSA.recover(digest, v, r, s);
        assertFalse(signer == signerAddr, "Signature was Valid");
    }

    function test_ClaimMintPass() public {
        bytes32 digest = mintPass.generateTypedDataHash(claimIndex, claimerAddr, "");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        mintPass.claimMintPass(claimIndex, "", abi.encode(v, r, s));
        assertTrue(mintPass.isClaimed(claimIndex), "Mint pass not claimed");
    }

    function test_RevertsWhen_AlreadyClaimed_ClaimMintPass() public {
        bytes32 digest = mintPass.generateTypedDataHash(claimIndex, claimerAddr, "");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        mintPass.claimMintPass(claimIndex, "", abi.encode(v, r, s));
        assertTrue(mintPass.isClaimed(claimIndex), "Mint pass not claimed");
        vm.expectRevert(abi.encodeWithSelector(MintPass.PassAlreadyClaimed.selector));
        mintPass.claimMintPass(claimIndex, "", abi.encode(v, r, s));
    }

    function test_RevertsWhen_NotClaimer_ClaimMintPass() public {
        bytes32 digest = mintPass.generateTypedDataHash(claimIndex, claimerAddr, "");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        vm.prank(address(bob));
        vm.expectRevert(abi.encodeWithSelector(MintPass.InvalidSig.selector));
        mintPass.claimMintPass(claimIndex, "", abi.encode(v, r, s));
        assertTrue(!mintPass.isClaimed(claimIndex), "Mint was claimed");
    }
}
