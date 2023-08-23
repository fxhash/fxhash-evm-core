// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxRandomizer/FxRandomizer.t.sol";

contract RequestRandomness is IFxSeedConsumer, FxRandomizerTest {
    bytes32 internal seed;

    function fulfillSeedRequest(uint256, /* _id */ bytes32 _seed) external {
        seed = _seed;
    }

    function test_requestRandomness() public {
        // Call the requestRandomness function passing a token ID
        randomizer.requestRandomness(123);

        bytes32 expectedSeed = keccak256(
            bytes.concat(keccak256(abi.encode(blockhash(block.number - 1), address(this), 123)))
        );
        assertEq(seed, expectedSeed);
    }
}
