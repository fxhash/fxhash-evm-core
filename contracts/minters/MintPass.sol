// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IMinter} from "contracts/interfaces/IMinter.sol";
import {Minted} from "contracts/minters/Minted.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MintPass is IMinter {
    using ECDSA for bytes32;

    address FXHASH_AUTHORITY;
    mapping(address => mapping(uint256 => uint256)) public redeemedBitMaps;

    error AlreadyClaimed();
    error InvalidSig();

    /// should integrate delegate cash

    function setMintDetails(uint256, uint256, uint256, bytes calldata) external {}

    function isClaimed(address _token, uint256 _index) public view returns (bool) {
        uint256 claimedWordIndex = _index / 256;
        uint256 claimedBitIndex = _index % 256;
        uint256 claimedWord = redeemedBitMaps[_token][claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function mint(
        address _token,
        address _redeemer,
        /// this should be msg.sender or vault
        uint256 _index,
        bytes calldata _mintCode,
        bytes calldata sig,
        address _to
    ) external {
        if (isClaimed(_token, _index)) revert AlreadyClaimed();
        bytes32 hash = keccak256(abi.encodePacked(_token, msg.sender, _index, _mintCode));
        if (hash.toEthSignedMessageHash().recover(sig) != FXHASH_AUTHORITY) revert InvalidSig();
        _setClaimed(_token, _index);
        Minted(_token).mint(1, _mintCode, _to);
    }

    function _setClaimed(address _token, uint256 _index) private {
        uint256 claimedWordIndex = _index / 256;
        uint256 claimedBitIndex = _index % 256;
        redeemedBitMaps[_token][claimedWordIndex] =
            redeemedBitMaps[_token][claimedWordIndex] |
            (1 << claimedBitIndex);
    }
}
