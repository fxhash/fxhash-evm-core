// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "contracts/abstract/admin/FxHashAdminVerify.sol";

abstract contract AddressConfig is FxHashAdminVerify {
    mapping(string => address) addresses;

    function setAddress(
        string calldata key,
        address value
    ) external onlyFxHashAdmin {
        require(value != address(0), "Address is null");
        addresses[key] = value;
    }
}
