// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract Admin is AccessControl {
    modifier onlyAdmin() {
        require(
            AccessControl.hasRole(
                AccessControl.DEFAULT_ADMIN_ROLE,
                _msgSender()
            ),
            "Caller is not an admin"
        );
        _;
    }

    // Function to grant the ADMIN_ROLE to an address
    function grantAdminRole(address _admin) public onlyAdmin {
        AccessControl.grantRole(AccessControl.DEFAULT_ADMIN_ROLE, _admin);
    }

    // Function to revoke the ADMIN_ROLE from an address
    function revokeAdminRole(address _admin) public onlyAdmin {
        AccessControl.revokeRole(AccessControl.DEFAULT_ADMIN_ROLE, _admin);
    }
}
