// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MintPass} from "src/utils/MintPass-EIP712.sol";
import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";

contract MockMintPass is MintPass {
    BitMaps.BitMap internal _bitmap;

    constructor(address _signer) MintPass(_signer) {}

    function claimMintPass(uint256 _index, bytes calldata _mintCode, bytes calldata _signature)
        external
    {
        _claimMintPass(_bitmap, _index, _mintCode, _signature);
    }

    function isClaimed(uint256 _index) external view returns (bool) {
        return _isClaimed(_bitmap, _index);
    }

    function genTypedDataHash(uint256 _index, address _user, bytes calldata _mintCode)
        external
        view
        returns (bytes32)
    {
        return _genTypedDataHash(_index, _user, _mintCode);
    }

    function claimTypeHash() external pure returns (bytes32) {
        return _CLAIM_TYPEHASH;
    }
}
