// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/Allowlist/AllowlistTest.t.sol";

contract ClaimSlot is AllowlistTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_ClaimSlot() public {
        proof = getProof(merkleTree, index - 1);
        vm.prank(alice);
        allowlist.claimSlot(token, index, PRICE, proof);

        assertTrue(allowlist.isClaimed(index));
    }

    function test_ClaimMultipleSlots() public {
        proof = getProof(merkleTree, index - 1);
        vm.prank(alice);
        allowlist.claimSlot(token, index, PRICE, proof);
        assertTrue(allowlist.isClaimed(index));

        index = 5;
        proof = getProof(merkleTree, index - 1);
        vm.prank(alice);
        allowlist.claimSlot(token, index, PRICE, proof);
        assertTrue(allowlist.isClaimed(index));
    }

    function test_RevertsWhen_NotClaimer() public {
        proof = getProof(merkleTree, index - 1);
        vm.expectRevert(abi.encodeWithSelector(INVALID_PROOF_ERROR));
        allowlist.claimSlot(token, index, PRICE, proof);
    }

    function test_RevertsWhen_AlreadyClaimed() public {
        proof = getProof(merkleTree, index - 1);
        vm.prank(alice);
        allowlist.claimSlot(token, index, PRICE, proof);

        vm.expectRevert(abi.encodeWithSelector(ALREADY_CLAIMED_ERROR));
        vm.prank(alice);
        allowlist.claimSlot(token, index, PRICE, proof);
    }
}
