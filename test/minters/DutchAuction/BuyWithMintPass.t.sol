// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/DutchAuction/DutchAuctionTest.t.sol";

contract BuyWithMintPass is DutchAuctionTest {
    // State
    uint256 internal claimIndex;
    uint256 internal signerNonce;

    // Errors
    bytes4 internal INVALID_SIGNATURE_ERROR = MintPass.InvalidSignature.selector;
    bytes4 internal PASS_ALREADY_CLAIMED_ERROR = MintPass.PassAlreadyClaimed.selector;

    function setUp() public override {
        quantity = 1;
        signerPk = 1;
        signerNonce = 1;
        signerAddr = vm.addr(signerPk);
        super.setUp();
    }

    function test_BuyWithMintPass() public {
        digest = dutchAuction.generateTypedDataHash(fxGenArtProxy, reserveId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(signerPk, digest);
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

    function test_RevertsWhen_NotClaimer() public {
        digest = dutchAuction.generateTypedDataHash(fxGenArtProxy, reserveId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(signerPk, digest);
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

    function test_RevertsWhen_InvalidSignature() public {
        digest = dutchAuction.generateTypedDataHash(fxGenArtProxy, reserveId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(2, digest);
        vm.prank(alice);
        vm.expectRevert(INVALID_SIGNATURE_ERROR);
        dutchAuction.buyMintPass{value: quantity * price}(
            fxGenArtProxy,
            reserveId,
            quantity,
            alice,
            claimIndex,
            abi.encodePacked(r, s, v)
        );
    }

    function test_RevertsWhen_PassAlreadyClaimed() public {
        digest = dutchAuction.generateTypedDataHash(fxGenArtProxy, reserveId, signerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(signerPk, digest);
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
        vm.expectRevert(PASS_ALREADY_CLAIMED_ERROR);
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
