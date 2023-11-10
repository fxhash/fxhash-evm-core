// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/DutchAuction/DutchAuctionTest.t.sol";

contract BuyWithMintPass is DutchAuctionTest {
    uint8 internal v;
    bytes32 internal r;
    bytes32 internal s;
    bytes32 internal digest;
    uint256 internal claimIndex;
    uint256 internal mintPassSignerNonce;

    bytes4 internal INVALID_SIGNATURE_ERROR = MintPass.InvalidSignature.selector;
    bytes4 internal PASS_ALREADY_CLAIMED_ERROR = MintPass.PassAlreadyClaimed.selector;

    function setUp() public override {
        quantity = 1;
        mintPassSignerPk = 1;
        mintPassSignerNonce = 1;
        mintPassSigner = vm.addr(mintPassSignerPk);
        super.setUp();
    }

    function test_BuyWithMintPass() public {
        digest = dutchAuction.generateTypedDataHash(fxGenArtProxy, reserveId, mintPassSignerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(mintPassSignerPk, digest);
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
        digest = dutchAuction.generateTypedDataHash(fxGenArtProxy, reserveId, mintPassSignerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(mintPassSignerPk, digest);
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
        digest = dutchAuction.generateTypedDataHash(fxGenArtProxy, reserveId, mintPassSignerNonce, claimIndex, alice);
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
        digest = dutchAuction.generateTypedDataHash(fxGenArtProxy, reserveId, mintPassSignerNonce, claimIndex, alice);
        (v, r, s) = vm.sign(mintPassSignerPk, digest);
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
