// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxPseudoRandomizer/FxPseudoRandomizerTest.t.sol";

contract RequestRandomness is ISeedConsumer, FxPseudoRandomizerTest {
    function fulfillSeedRequest(uint256, bytes32 _seed) external {
        genArtInfo.seed = _seed;
    }

    function test_requestRandomness() public {
        fxPseudoRandomizer.requestRandomness(tokenId);
        seed = fxPseudoRandomizer.generateSeed(tokenId);
        assertEq(genArtInfo.seed, seed);
    }
}
