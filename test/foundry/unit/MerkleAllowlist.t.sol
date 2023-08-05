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

contract Claim is MerkleAllowlistTest {
    function test_Claim() public {}
}
