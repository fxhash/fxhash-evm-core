// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPrice/FixedPriceTest.t.sol";

contract BuyWithMintPass is FixedPriceTest {
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

    function test_RevertsWhen_PublicPurchase() public {
        vm.expectRevert(ADDRESS_ZERO_ERROR);
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
    }

    function test_BuyWithMintPass() public {
        digest = fixedPrice.generateTypedDataHash(fxGenArtProxy, mintId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(signerPk, digest);
        vm.prank(alice);
        (platformFee, , ) = feeManager.calculateFees(fxGenArtProxy, price, quantity);
        price = quantity * price + platformFee;
        fixedPrice.buyMintPass{value: price}(
            fxGenArtProxy,
            mintId,
            quantity,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v)
        );
    }

    function test_RevertsWhen_NotClaimer() public {
        digest = fixedPrice.generateTypedDataHash(fxGenArtProxy, mintId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(signerPk, digest);
        vm.prank(bob);
        vm.expectRevert();
        fixedPrice.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            mintId,
            quantity,
            bob,
            claimIndex,
            abi.encodePacked(r, s, v)
        );
    }

    function test_RevertsWhen_SignatureInvalid() public {
        digest = fixedPrice.generateTypedDataHash(fxGenArtProxy, mintId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(2, digest);
        vm.prank(alice);
        vm.expectRevert(INVALID_SIGNATURE_ERROR);
        fixedPrice.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            mintId,
            quantity,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v)
        );
    }

    function test_RevertsWhen_PassAlreadyClaimed() public {
        digest = fixedPrice.generateTypedDataHash(fxGenArtProxy, mintId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(signerPk, digest);
        vm.prank(alice);
        (platformFee, , ) = feeManager.calculateFees(fxGenArtProxy, price, quantity);
        price = quantity * price + platformFee;
        fixedPrice.buyMintPass{value: price}(
            fxGenArtProxy,
            mintId,
            quantity,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v)
        );

        vm.prank(alice);
        vm.expectRevert(PASS_ALREADY_CLAIMED_ERROR);
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
