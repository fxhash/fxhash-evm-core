// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IDelegateCash {
    function checkDelegateForAll(address delegate, address vault) external view returns (bool);
}
