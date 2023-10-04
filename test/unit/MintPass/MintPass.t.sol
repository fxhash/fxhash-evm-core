// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract MintPassTest is BaseTest {
    MockMintPass internal mintPass;
    uint256 internal claimIndex = 1;
    address internal claimerAddress = address(this);
    uint256 internal signerPk = 1;
    address internal signerAddress = vm.addr(signerPk);

    function setUp() public override {
        mintPass = new MockMintPass(signerAddress);
    }
}
