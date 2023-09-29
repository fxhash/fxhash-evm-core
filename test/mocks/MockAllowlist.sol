// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Allowlist} from "src/minters/extensions/Allowlist.sol";
import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";

contract MockAllowlist is Allowlist {
    using BitMaps for BitMaps.BitMap;

    BitMaps.BitMap internal _bitmap;
    bytes32 public merkleRoot;

    function claimSlot(
        address _token,
        uint256 _index,
        uint256 _price,
        bytes32[] memory _proof
    ) external {
        _claimSlot(_bitmap, _token, _index, _price, _proof);
    }

    function setMerkleRoot(bytes32 _merkleRoot) external {
        merkleRoot = _merkleRoot;
    }

    function isClaimed(uint256 _index) external view returns (bool) {
        return _bitmap.get(_index);
    }

    function _getMerkleRoot(address /* _token */ ) internal view override returns (bytes32) {
        return merkleRoot;
    }
}
