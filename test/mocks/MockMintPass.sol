// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MintPass} from "src/minters/extensions/MintPass.sol";
import {CLAIM_TYPEHASH} from "src/utils/Constants.sol";

contract MockMintPass is MintPass {
    using BitMaps for BitMaps.BitMap;

    BitMaps.BitMap internal _bitmap;
    address internal signer;

    constructor(address _signer) MintPass() {
        signer = _signer;
    }

    function claimMintPass(uint256 _index, bytes calldata _signature) external {
        _claimMintPass(address(0), 0, _index, _signature, _bitmap);
    }

    function isClaimed(uint256 _index) external view returns (bool) {
        return _bitmap.get(_index);
    }

    function claimTypeHash() external pure returns (bytes32) {
        return CLAIM_TYPEHASH;
    }

    function _isSigningAuthority(address _signer, address, uint256) internal view override returns (bool) {
        return _signer == signer;
    }
}
