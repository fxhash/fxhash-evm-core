// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/FixedPrice/FixedPriceTest.t.sol";

contract BuyWithMintPass is FixedPriceTest {
    uint256 internal claimIndex;

    function setUp() public override {
        quantity = 1;
        mintPassSignerPk = 1;
        mintPassSigner = vm.addr(mintPassSignerPk);
        super.setUp();
    }

    function test_RevertsWhen_PublicPurchase() public {
        vm.expectRevert(NO_PUBLIC_MINT_ERROR);
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
    }

    function test_BuyWithMintPass() public {
        bytes32 digest = fixedPrice.generateTypedDataHash(claimIndex, alice);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(mintPassSignerPk, digest);
        vm.prank(alice);
        fixedPrice.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            mintId,
            quantity,
            alice,
            claimIndex,
            abi.encode(v, r, s)
        );
    }

    function test_RevertsWhen_NotClaimer_BuyWithMintPass() public {
        bytes32 digest = fixedPrice.generateTypedDataHash(claimIndex, alice);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(mintPassSignerPk, digest);
        vm.prank(bob);
        vm.expectRevert();
        fixedPrice.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            mintId,
            quantity,
            alice,
            claimIndex,
            abi.encode(v, r, s)
        );
    }

    function test_RevertsWhen_SignatureInvalid_BuyWithMintPass() public {
        bytes32 digest = fixedPrice.generateTypedDataHash(claimIndex, alice);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(2, digest);
        vm.prank(alice);
        vm.expectRevert();
        fixedPrice.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            mintId,
            quantity,
            alice,
            claimIndex,
            abi.encode(v, r, s)
        );
    }

    function test_RevertsWhen_MintPassAlreadyClaimed_BuyWithMintPass() public {
        bytes32 digest = fixedPrice.generateTypedDataHash(claimIndex, alice);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(mintPassSignerPk, digest);
        vm.prank(alice);
        fixedPrice.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            mintId,
            quantity,
            alice,
            claimIndex,
            abi.encode(v, r, s)
        );

        vm.prank(alice);
        vm.expectRevert();
        fixedPrice.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            mintId,
            quantity,
            alice,
            claimIndex,
            abi.encode(v, r, s)
        );
    }
}
