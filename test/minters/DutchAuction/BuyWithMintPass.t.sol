// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/DutchAuction/DutchAuctionTest.t.sol";

contract BuyWithMintPass is DutchAuctionTest {
    uint256 internal claimIndex;

    function setUp() public override {
        quantity = 1;
        mintPassSignerPk = 1;
        mintPassSigner = vm.addr(mintPassSignerPk);
        super.setUp();
    }

    function test_RevertsWhen_PublicPurchase() public {
        vm.expectRevert();
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
    }

    function test_BuyWithMintPass() public {
        bytes32 digest = dutchAuction.generateTypedDataHash(fxGenArtProxy, reserveId, claimIndex, alice);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(mintPassSignerPk, digest);
        vm.prank(alice);
        dutchAuction.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            reserveId,
            quantity,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v)
        );
    }

    function test_RevertsWhen_NotClaimer_BuyWithMintPass() public {
        bytes32 digest = dutchAuction.generateTypedDataHash(fxGenArtProxy, reserveId, claimIndex, alice);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(mintPassSignerPk, digest);
        vm.prank(bob);
        vm.expectRevert();
        dutchAuction.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            reserveId,
            quantity,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v)
        );
    }

    function test_RevertsWhen_SignatureInvalid_BuyWithMintPass() public {
        bytes32 digest = dutchAuction.generateTypedDataHash(fxGenArtProxy, reserveId, claimIndex, alice);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(2, digest);
        vm.prank(alice);
        vm.expectRevert();
        dutchAuction.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            reserveId,
            quantity,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v)
        );
    }

    function test_RevertsWhen_MintPassAlreadyClaimed_BuyWithMintPass() public {
        bytes32 digest = dutchAuction.generateTypedDataHash(fxGenArtProxy, reserveId, claimIndex, alice);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(mintPassSignerPk, digest);
        vm.prank(alice);
        dutchAuction.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            reserveId,
            quantity,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v)
        );

        vm.prank(alice);
        vm.expectRevert();
        dutchAuction.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            reserveId,
            quantity,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v)
        );
    }
}
