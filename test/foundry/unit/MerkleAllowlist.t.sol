// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {console} from "forge-std/Test.sol";
import {Base} from "test/foundry/Base.t.sol";
import {IWETH} from "contracts/interfaces/IWETH.sol";
import {FixedPriceMint} from "contracts/minters/FixedPriceMint.sol";
import {Minted} from "contracts/minters/base/Minted.sol";
import {MockGenerativeToken, Reserve} from "test/mocks/MockGenerativeToken.sol";
import {IMinter} from "contracts/interfaces/IMinter.sol";
import {Merkle} from "test/foundry/utils/Merkle.sol";
import {MockMerkleAllowlist} from "test/mocks/MockMerkleAllowlist.sol";

contract MerkleAllowlistTest is Base {
    MockMerkleAllowlist public mockAllowlist;
    Merkle public merkleBase;
    bytes32 public merkleRoot;
    address[6] public allowlist;
    bytes32[] public allowlistLeaves;

    function setUp() public override {
        super.setUp();
        allowlist = [address(42), address(42), address(69), address(69), address(2), address(2)];
        merkleBase = new Merkle();
        for (uint256 i; i < allowlist.length; i++) {
            allowlistLeaves.push(keccak256(abi.encode(i, allowlist[i])));
        }
        merkleRoot = merkleBase.getRoot(allowlistLeaves);
        mockAllowlist = new MockMerkleAllowlist();
    }
}

contract SetRoot is MerkleAllowlistTest {
    function test_setRoot() public {}

    function test_RevertsIf_IsZero() public {}
}

contract Claim is MerkleAllowlistTest {
    function test_Claim() public {}

    function test_WhenDelegated_AsDelegate() public {}

    function test_RevertsWhenNotDelegated_AsDelegate() public {}

    function test_RevertsWhenAlreadyClaimed() public {}
}

contract IsClaimed is MerkleAllowlistTest {
    function test_IsClaimed() public {}

    function test_WhenClaimed_ReturnsTrue() public {}

    function test_WhenUnclaimed_ReturnsFalse() public {}

    function test_RevertsWhen_RootNotSet() public {}
}
