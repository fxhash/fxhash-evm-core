// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/abstract/admin/FxHashAdmin.sol";

abstract contract AddressConfig is FxHashAdmin {
    mapping(string => address) addresses;

    function setAddress(
        string calldata key,
        address value
    ) external onlyFxHashAdmin {
        require(value != address(0), "Address is null");
        addresses[key] = value;
    }
}
