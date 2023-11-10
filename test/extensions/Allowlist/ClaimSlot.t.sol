// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/extensions/Allowlist/AllowlistTest.t.sol";

contract ClaimSlot is AllowlistTest {
    function test_ClaimSlot() public {
        proof = getProof(merkleTree, index - 1);
        vm.prank(alice);
        allowlist.claimSlot(token, index, proof);
        assertTrue(allowlist.isClaimed(index));
    }

    function test_ClaimMultipleSlots() public {
        proof = getProof(merkleTree, index - 1);
        vm.prank(alice);
        allowlist.claimSlot(token, index, proof);
        assertTrue(allowlist.isClaimed(index));

        index = 5;
        proof = getProof(merkleTree, index - 1);
        vm.prank(alice);
        allowlist.claimSlot(token, index, proof);
        assertTrue(allowlist.isClaimed(index));
    }

    function test_RevertsWhen_InvalidProof() public {
        proof = getProof(merkleTree, index - 1);
        vm.expectRevert(abi.encodeWithSelector(INVALID_PROOF_ERROR));
        allowlist.claimSlot(token, index, proof);
    }

    function test_RevertsWhen_AlreadyClaimed() public {
        proof = getProof(merkleTree, index - 1);
        vm.prank(alice);
        allowlist.claimSlot(token, index, proof);

        vm.expectRevert(abi.encodeWithSelector(SLOT_ALREADY_CLAIMED_ERROR));
        vm.prank(alice);
        allowlist.claimSlot(token, index, proof);
    }
}
