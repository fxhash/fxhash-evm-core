// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MintPass} from "src/utils/MintPass.sol";

contract MockMintPass is MintPass {
    constructor(address _signer) MintPass(_signer) {}
}
