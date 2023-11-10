// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/FixedPrice/FixedPriceTest.t.sol";

contract BuyWithMintPass is FixedPriceTest {
    uint256 internal claimIndex;
    uint256 internal signerNonce;

    function setUp() public override {
        quantity = 1;
        signerNonce = 1;
        signerPk = 1;
        signerAddr = vm.addr(signerPk);
        super.setUp();
    }

    function test_RevertsWhen_PublicPurchase() public {
        vm.expectRevert(ADDRESS_ZERO_ERROR);
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
    }

    function test_BuyWithMintPass() public {
        digest = fixedPrice.generateTypedDataHash(fxGenArtProxy, mintId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(signerPk, digest);
        vm.prank(alice);
        fixedPrice.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            mintId,
            quantity,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v)
        );
    }

    function test_RevertsWhen_NotClaimer_BuyWithMintPass() public {
        digest = fixedPrice.generateTypedDataHash(fxGenArtProxy, mintId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(signerPk, digest);
        vm.prank(bob);
        vm.expectRevert();
        fixedPrice.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            mintId,
            quantity,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v)
        );
    }

    function test_RevertsWhen_SignatureInvalid_BuyWithMintPass() public {
        digest = fixedPrice.generateTypedDataHash(fxGenArtProxy, mintId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(2, digest);
        vm.prank(alice);
        vm.expectRevert();
        fixedPrice.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            mintId,
            quantity,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v)
        );
    }

    function test_RevertsWhen_MintPassAlreadyClaimed_BuyWithMintPass() public {
        digest = fixedPrice.generateTypedDataHash(fxGenArtProxy, mintId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(signerPk, digest);
        vm.prank(alice);
        fixedPrice.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            mintId,
            quantity,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v)
        );

        vm.prank(alice);
        vm.expectRevert();
        fixedPrice.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            mintId,
            quantity,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v)
        );
    }
}
