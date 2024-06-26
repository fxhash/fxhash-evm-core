// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

import {MockAllowlist} from "test/mocks/MockAllowlist.sol";

contract AllowlistTest is BaseTest, StandardMerkleTree {
    // Contracts
    MockAllowlist internal allowlist;

    // State
    address internal token;
    bytes32[] internal merkleTree;
    bytes32[] internal proof;
    uint256 internal index;

    // Errors
    bytes4 internal INVALID_PROOF_ERROR = Allowlist.InvalidProof.selector;
    bytes4 internal SLOT_ALREADY_CLAIMED_ERROR = Allowlist.SlotAlreadyClaimed.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _mockAllowlist(admin);
        _configureAllowlist();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                MERKLE ROOT
    //////////////////////////////////////////////////////////////////////////*/

    function test_MerkleRoot() public {
        assertEq(allowlist.merkleRoot(), merkleRoot);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal override {
        super._initializeState();
        index = 1;
    }

    function _mockAllowlist(address _admin) internal prank(_admin) {
        allowlist = new MockAllowlist();
    }

    function _configureAllowlist() internal {
        address[5] memory users = [alice, bob, eve, susan, alice];
        for (uint256 i; i < users.length; ++i) {
            merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(i + 1, users[i])))));
        }
        merkleRoot = getRoot(merkleTree);
        allowlist.setMerkleRoot(merkleRoot);
    }
}
