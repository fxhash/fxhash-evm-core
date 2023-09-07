// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/Allowlist/Allowlist.t.sol";

contract ClaimAllowlistSlotTest is AllowlistTest {
    function setUp() public override {
        super.setUp();
        merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(1, 0.1 ether, alice)))));
        merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(2, 0.1 ether, bob)))));
        merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(3, 0.1 ether, eve)))));
        merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(4, 0.1 ether, susan)))));
        merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(5, 0.1 ether, alice)))));
        merkleRoot = getRoot(merkleTree);
        allowlist.setMerkleRoot(merkleRoot);
    }

    function test_ClaimMerkleTreeSlot() public {
        bytes32[] memory aliceIndex1Proof = getProof(merkleTree, 0);
        vm.prank(alice);
        allowlist.claimSlot(address(0), 1, 0.1 ether, aliceIndex1Proof);
    }

    function test_ClaimsMultipleSlots() public {
        bytes32[] memory aliceIndex1Proof = getProof(merkleTree, 0);
        vm.prank(alice);
        allowlist.claimSlot(address(0), 1, 0.1 ether, aliceIndex1Proof);

        bytes32[] memory aliceIndex4Proof = getProof(merkleTree, 4);
        vm.prank(alice);
        allowlist.claimSlot(address(0), 5, 0.1 ether, aliceIndex4Proof);
    }

    function test_RevertsWhen_NotClaimer() public {
        bytes32[] memory aliceIndex1Proof = getProof(merkleTree, 0);
        vm.expectRevert(abi.encodeWithSelector(Allowlist.InvalidProof.selector));
        allowlist.claimSlot(address(0), 1, 0.1 ether, aliceIndex1Proof);
    }

    function test_RevertsWhen_AlreadyClaimed() public {
        bytes32[] memory aliceIndex1Proof = getProof(merkleTree, 0);
        vm.prank(alice);
        allowlist.claimSlot(address(0), 1, 0.1 ether, aliceIndex1Proof);
        vm.expectRevert(abi.encodeWithSelector(Allowlist.AlreadyClaimed.selector));
        vm.prank(alice);
        allowlist.claimSlot(address(0), 1, 0.1 ether, aliceIndex1Proof);
    }
}
