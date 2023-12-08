// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Allowlist} from "src/minters/extensions/Allowlist.sol";
import {LibBitmap} from "solady/src/utils/LibBitmap.sol";

contract MockAllowlist is Allowlist {
    LibBitmap.Bitmap internal _bitmap;
    bytes32 public merkleRoot;

    function claimSlot(address _token, uint256 _index, address _to, bytes32[] memory _proof) external {
        _claimSlot(_token, 0, _index, _to, _proof, _bitmap);
    }

    function setMerkleRoot(bytes32 _merkleRoot) external {
        merkleRoot = _merkleRoot;
    }

    function isClaimed(uint256 _index) external view returns (bool) {
        return LibBitmap.get(_bitmap, _index);
    }

    function _getMerkleRoot(address, uint256) internal view override returns (bytes32) {
        return merkleRoot;
    }
}
