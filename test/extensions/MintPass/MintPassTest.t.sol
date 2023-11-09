// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {ECDSA} from "openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MintPass} from "src/minters/extensions/MintPass.sol";
import {MockMintPass} from "test/mocks/MockMintPass.sol";

contract MintPassTest is BaseTest {
    // Contracts
    MockMintPass internal mintPass;

    // State
    uint256 internal claimIndex = 1;
    address internal claimerAddr = address(this);
    uint256 internal signerPk = 1;
    address internal signerAddr = vm.addr(signerPk);

    // Errors
    bytes4 internal INVALID_SIGNATURE_ERROR = MintPass.InvalidSignature.selector;
    bytes4 internal PASS_ALREADY_CLAIMED_ERROR = MintPass.PassAlreadyClaimed.selector;

    function setUp() public override {
        _mockMintPass(admin, signerAddr);
    }

    function _mockMintPass(address _admin, address _signer) internal prank(_admin) {
        mintPass = new MockMintPass(_signer);
    }
}
