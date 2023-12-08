// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibBitmap} from "solady/src/utils/LibBitmap.sol";
import {MintPass} from "src/minters/extensions/MintPass.sol";

import {CLAIM_TYPEHASH} from "src/utils/Constants.sol";

contract MockMintPass is MintPass {
    LibBitmap.Bitmap internal _bitmap;

    constructor(address _signer) MintPass() {
        signingAuthorities[address(0)][0] = _signer;
    }

    function claimMintPass(uint256 _index, address _to, bytes calldata _signature) external {
        _claimMintPass(address(0), 0, _index, _to, _signature, _bitmap);
    }

    function isClaimed(uint256 _index) external view returns (bool) {
        return LibBitmap.get(_bitmap, _index);
    }

    function claimTypeHash() external pure returns (bytes32) {
        return CLAIM_TYPEHASH;
    }
}
