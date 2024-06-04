// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPriceParams/FixedPriceParamsTest.t.sol";

contract BuyMintPass is FixedPriceParamsTest {
    // State
    uint256 internal claimIndex;
    uint256 internal signerNonce;

    // Errors
    bytes4 internal INVALID_SIGNATURE_ERROR = MintPass.InvalidSignature.selector;
    bytes4 internal PASS_ALREADY_CLAIMED_ERROR = MintPass.PassAlreadyClaimed.selector;

    function setUp() public override {
        quantity = 1;
        signerNonce = 1;
        signerPk = 1;
        signerAddr = vm.addr(signerPk);
        super.setUp();
    }

    function test_BuyWithMintPass() public {
        digest = fixedPriceParams.generateTypedDataHash(fxGenArtProxy, mintId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(signerPk, digest);
        vm.prank(alice);
        fixedPriceParams.buyMintPass{value: price}(
            fxGenArtProxy,
            mintId,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v),
            fxParams
        );
    }

    function test_BuyWithMintPass_RevertsWhen_PublicPurchase() public {
        vm.expectRevert(ADDRESS_ZERO_ERROR);
        fixedPriceParams.buy{value: price}(fxGenArtProxy, mintId, alice, fxParams);
    }

    function test_BuyWithMintPass_RevertsWhen_NotClaimer() public {
        digest = fixedPriceParams.generateTypedDataHash(fxGenArtProxy, mintId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(signerPk, digest);
        vm.prank(bob);
        vm.expectRevert();
        fixedPriceParams.buyMintPass{value: price}(
            fxGenArtProxy,
            mintId,
            bob,
            claimIndex,
            abi.encodePacked(r, s, v),
            fxParams
        );
    }

    function test_BuyWithMintPass_RevertsWhen_SignatureInvalid() public {
        digest = fixedPriceParams.generateTypedDataHash(fxGenArtProxy, mintId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(2, digest);
        vm.prank(alice);
        vm.expectRevert(INVALID_SIGNATURE_ERROR);
        fixedPriceParams.buyMintPass{value: price}(
            fxGenArtProxy,
            mintId,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v),
            fxParams
        );
    }

    function test_BuyWithMintPass_RevertsWhen_PassAlreadyClaimed() public {
        digest = fixedPriceParams.generateTypedDataHash(fxGenArtProxy, mintId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(signerPk, digest);
        vm.prank(alice);
        fixedPriceParams.buyMintPass{value: price}(
            fxGenArtProxy,
            mintId,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v),
            fxParams
        );

        vm.prank(alice);
        vm.expectRevert(PASS_ALREADY_CLAIMED_ERROR);
        fixedPriceParams.buyMintPass{value: price}(
            fxGenArtProxy,
            mintId,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v),
            fxParams
        );
    }
}
