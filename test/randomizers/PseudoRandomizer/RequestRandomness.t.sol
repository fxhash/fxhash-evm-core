// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/randomizers/PseudoRandomizer/PseudoRandomizerTest.t.sol";
import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";

contract RequestRandomness is ISeedConsumer, PseudoRandomizerTest {
    function fulfillSeedRequest(uint256, bytes32 _seed) external {
        genArtInfo.seed = _seed;
    }

    function test_requestRandomness() public {
        pseudoRandomizer.requestRandomness(tokenId);
        seed = pseudoRandomizer.generateSeed(tokenId);
        assertEq(genArtInfo.seed, seed);
    }
}
