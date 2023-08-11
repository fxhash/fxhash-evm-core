// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IMinter, Reserve} from "src/interfaces/IMinter.sol";

/// implemented by GenTk
abstract contract Minted {
    function feeReceiver() external virtual returns (address);

    function mint(uint256, address) external virtual;

    function mint(uint256, bytes calldata, address) external virtual;

    function _registerMinter(address _minter, Reserve calldata _reserve, bytes calldata _minterData)
        internal
    {
        IMinter(_minter).setMintDetails(_reserve, _minterData);
    }
}
