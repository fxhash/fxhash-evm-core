// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPrice/FixedPriceTest.t.sol";

contract BuyAllowlist is FixedPriceTest, StandardMerkleTree {
    uint256[] internal claimIndexes;
    bytes32[] internal merkleTree;
    bytes32[][] internal aliceProofs;

    function setUp() public override {
        _createAccounts();
        address[5] memory users = [alice, bob, eve, susan, alice];
        for (uint256 i; i < users.length; ++i) {
            merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(i + 1, users[i])))));
        }
        merkleRoot = getRoot(merkleTree);

        aliceProofs.push(getProof(merkleTree, 0));
        assertEq(aliceProofs.length, 1);
        claimIndexes.push(1);
        super.setUp();
    }

    function test_RevertsWhen_PublicPurchase() public {
        vm.expectRevert(NO_PUBLIC_MINT_ERROR);
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
    }

    function test_BuyAllowlist() public {
        vm.prank(alice);
        (platformFee, , ) = feeManager.calculateFees(fxGenArtProxy, price, quantity);
        price = quantity * price + platformFee;
        fixedPrice.buyAllowlist{value: price}(fxGenArtProxy, mintId, alice, claimIndexes, aliceProofs);
    }

    function test_RevertsWhen_NotClaimer() public {
        vm.prank(bob);
        vm.expectRevert();
        fixedPrice.buyAllowlist{value: quantity * price}(fxGenArtProxy, mintId, bob, claimIndexes, aliceProofs);
    }

    function test_RevertsWhen_ProofsInvalid() public {
        aliceProofs[0].pop();
        vm.prank(alice);
        vm.expectRevert();
        fixedPrice.buyAllowlist{value: quantity * price}(fxGenArtProxy, mintId, alice, claimIndexes, aliceProofs);
    }

    function test_RevertsWhen_SlotAlreadyClaimed() public {
        vm.prank(alice);
        (platformFee, , ) = feeManager.calculateFees(fxGenArtProxy, price, quantity);
        price = quantity * price + platformFee;
        fixedPrice.buyAllowlist{value: quantity * price}(fxGenArtProxy, mintId, alice, claimIndexes, aliceProofs);

        vm.prank(alice);
        vm.expectRevert();
        fixedPrice.buyAllowlist{value: quantity * price}(fxGenArtProxy, mintId, alice, claimIndexes, aliceProofs);
    }
}
