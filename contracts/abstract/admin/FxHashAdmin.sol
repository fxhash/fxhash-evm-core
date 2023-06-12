// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "contracts/abstract/admin/Admin.sol";

abstract contract FxHashAdmin is Admin {
    bytes32 public constant FXHASH_ADMIN = keccak256("FXHASH_ADMIN");

    modifier onlyFxHashAdmin() {
        require(
            AccessControl.hasRole(FXHASH_ADMIN, _msgSender()),
            "Caller is not a FxHash admin"
        );
        _;
    }

    function grantFxHashAdminRole(address _admin) public onlyAdmin {
        AccessControl.grantRole(FXHASH_ADMIN, _admin);
    }

    function revokeFxHashAdminRole(address _admin) public onlyAdmin {
        AccessControl.revokeRole(FXHASH_ADMIN, _admin);
    }
}
