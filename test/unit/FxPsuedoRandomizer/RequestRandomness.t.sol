// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxPsuedoRandomizer/FxPsuedoRandomizerTest.t.sol";

contract RequestRandomness is IFxSeedConsumer, FxPsuedoRandomizerTest {
    function fulfillSeedRequest(
        uint256,
        /* _tokenId */
        bytes32 _seed
    ) external {
        genArtInfo.seed = _seed;
    }

    function test_requestRandomness() public {
        fxPsuedoRandomizer.requestRandomness(tokenId);
        seed = fxPsuedoRandomizer.generateSeed(tokenId);
        assertEq(genArtInfo.seed, seed);
    }
}
