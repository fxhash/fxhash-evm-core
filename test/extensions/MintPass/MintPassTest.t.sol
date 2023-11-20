// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

import {ECDSA} from "openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MockMintPass} from "test/mocks/MockMintPass.sol";

contract MintPassTest is BaseTest {
    // Contracts
    MockMintPass internal mintPass;

    // State
    uint256 internal claimIndex;
    address internal claimerAddr;

    // Errors
    bytes4 internal INVALID_SIGNATURE_ERROR = MintPass.InvalidSignature.selector;
    bytes4 internal PASS_ALREADY_CLAIMED_ERROR = MintPass.PassAlreadyClaimed.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public override {
        _initializeState();
        _mockMintPass(admin, signerAddr);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal override {
        super._initializeState();
        claimIndex = 1;
        claimerAddr = address(this);
        signerPk = 1;
        signerAddr = vm.addr(signerPk);
    }

    function _mockMintPass(address _admin, address _signer) internal prank(_admin) {
        mintPass = new MockMintPass(_signer);
    }
}
