// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/Allowlist/AllowlistTest.t.sol";

contract ClaimTest is AllowlistTest {
    function test_ClaimSlot() public {
        proof = getProof(merkleTree, 0);

        vm.prank(alice);
        allowlist.claimSlot(address(0), 1, 0.1 ether, proof);

        assertTrue(allowlist.isClaimed(1));
    }

    function test_ClaimsMultipleSlots() public {
        proof = getProof(merkleTree, 0);
        vm.prank(alice);
        allowlist.claimSlot(address(0), 1, 0.1 ether, proof);

        proof = getProof(merkleTree, 4);
        vm.prank(alice);
        allowlist.claimSlot(address(0), 5, 0.1 ether, proof);

        assertTrue(allowlist.isClaimed(1));
        assertTrue(allowlist.isClaimed(5));
    }

    function test_RevertsWhen_NotClaimer() public {
        proof = getProof(merkleTree, 0);

        vm.expectRevert(abi.encodeWithSelector(ERROR_INVALID_PROOF));
        allowlist.claimSlot(address(0), 1, 0.1 ether, proof);

        assertFalse(allowlist.isClaimed(1));
    }

    function test_RevertsWhen_AlreadyClaimed() public {
        proof = getProof(merkleTree, 0);
        vm.prank(alice);
        allowlist.claimSlot(address(0), 1, 0.1 ether, proof);

        vm.expectRevert(abi.encodeWithSelector(ERROR_ALREADY_CLAIMED));
        vm.prank(alice);
        allowlist.claimSlot(address(0), 1, 0.1 ether, proof);

        assertTrue(allowlist.isClaimed(1));
    }
}
