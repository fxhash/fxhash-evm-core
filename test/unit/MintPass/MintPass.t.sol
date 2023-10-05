// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract MintPassTest is BaseTest {
    // State
    uint256 internal claimIndex = 1;
    address internal claimerAddr = address(this);
    uint256 internal signerPk = 1;
    address internal signerAddr = vm.addr(signerPk);

    function setUp() public override {
        _mockMintPass(admin, signerAddr);
    }
}
