// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract AllowlistTest is BaseTest, StandardMerkleTree {
    // State
    address internal token;
    bytes32 internal merkleRoot;
    bytes32[] internal merkleTree;
    bytes32[] internal proof;
    uint256 internal index;

    // Errors
    bytes4 internal ALREADY_CLAIMED_ERROR = Allowlist.AlreadyClaimed.selector;
    bytes4 internal INVALID_PROOF_ERROR = Allowlist.InvalidProof.selector;

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

    function _configureAllowlist() internal {
        address[5] memory users = [alice, bob, eve, susan, alice];
        for (uint256 i; i < users.length; ++i) {
            merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(i + 1, PRICE, users[i])))));
        }
        merkleRoot = getRoot(merkleTree);
        allowlist.setMerkleRoot(merkleRoot);
    }
}
