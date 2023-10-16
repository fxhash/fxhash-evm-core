// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/DutchAuction/DutchAuctionTest.t.sol";

contract BuyAllowlist is DutchAuctionTest, StandardMerkleTree {
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
        vm.expectRevert();
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
    }

    function test_BuyAllowlist() public {
        vm.prank(alice);
        dutchAuction.buyAllowlist{value: quantity * price}(fxGenArtProxy, reserveId, alice, claimIndexes, aliceProofs);
    }

    function test_RevertsWhen_NotClaimer_BuyAllowlist() public {
        vm.prank(bob);
        vm.expectRevert();
        dutchAuction.buyAllowlist{value: quantity * price}(fxGenArtProxy, reserveId, alice, claimIndexes, aliceProofs);
    }

    function test_RevertsWhen_ProofsInvalid_BuyAllowlist() public {
        aliceProofs[0].pop();
        vm.prank(alice);
        vm.expectRevert();
        dutchAuction.buyAllowlist{value: quantity * price}(fxGenArtProxy, reserveId, alice, claimIndexes, aliceProofs);
    }

    function test_RevertsWhen_SlotAlreadyClaimed_BuyAllowlist() public {
        vm.prank(alice);
        dutchAuction.buyAllowlist{value: quantity * price}(fxGenArtProxy, reserveId, alice, claimIndexes, aliceProofs);

        vm.prank(alice);
        vm.expectRevert();
        dutchAuction.buyAllowlist{value: quantity * price}(fxGenArtProxy, reserveId, alice, claimIndexes, aliceProofs);
    }
}
