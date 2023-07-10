// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/abstract/admin/AdminVerify.sol";

abstract contract AddressConfig is AdminVerify {
    struct AddressEntry {
        string key;
        address value;
    }

    mapping(string => address) addresses;

    function setAddresses(
        AddressEntry[] calldata _addresses
    ) external onlyAdmin {
        for (uint256 i = 0; i < _addresses.length; i++) {
            require(_addresses[i].value != address(0), "Address is null");
            addresses[_addresses[i].key] = _addresses[i].value;
        }
    }
}
