// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxRandomizer/FxRandomizer.t.sol";

contract RequestRandomness is IFxSeedConsumer, FxRandomizerTest {
    function fulfillSeedRequest(uint256 _tokenId, bytes32 _seed) external {
        seed = _seed;
    }

    function test_requestRandomness() public {
        fxRandomizer.requestRandomness(tokenId);
        bytes32 expectedSeed = keccak256(
            abi.encodePacked(
                tokenId, address(this), block.number, block.timestamp, blockhash(block.number - 1)
            )
        );
        assertEq(seed, expectedSeed);
    }
}
