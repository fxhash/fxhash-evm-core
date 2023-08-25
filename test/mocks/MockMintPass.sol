// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MintPass} from "src/utils/MintPass.sol";
import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";

contract MockMintPass is MintPass {
    BitMaps.BitMap internal bitmap;

    constructor(address _signer) MintPass(_signer) {}

    function claimMintPass(uint256 _index, bytes calldata _mintCode, bytes calldata _sig)
        external
    {
        _claimMintPass(bitmap, _index, _mintCode, _sig);
    }

    function isClaimed(uint256 _index) external view returns (bool) {
        return _isClaimed(bitmap, _index);
    }
}
