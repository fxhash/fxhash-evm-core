// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IPFS_URL} from "src/utils/Constants.sol";

/**
 * @title LibIPFSEncoder
 * @author fx(hash)
 * @custom:coauthor lukasz-glen (https://github.com/lukasz-glen)
 * @notice Library for encoding IPFS CID hashes
 */
library LibIPFSEncoder {
    /**
     * @dev Encodes IPFS CID hash to URL string format
     */
    function encodeURL(bytes32 _value) internal pure returns (string memory) {
        if (_value == bytes32(0)) return "";
        uint256 value = uint256(_value);
        bytes memory url = IPFS_URL;
        uint256 remainder;
        uint256 i = 53;
        unchecked {
            while (i > 7) {
                i--;
                uint256 a = uint256(uint8(url[i])) + (value % 58) + remainder;
                remainder = a / 58;
                a %= 58;
                value /= 58;
                if (a < 9) {
                    // 1 - 9
                    a += 49;
                } else if (a < 17) {
                    // A - H
                    a += 56;
                } else if (a < 22) {
                    // J - N
                    a += 57;
                } else if (a < 33) {
                    // P - Z
                    a += 58;
                } else if (a < 44) {
                    // a - k
                    a += 64;
                } else {
                    // m - z
                    a += 65;
                }
                url[i] = bytes1(uint8(a));
            }
            return string(url);
        }
    }
}
