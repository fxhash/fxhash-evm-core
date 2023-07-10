// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "contracts/abstract/admin/AdminVerify.sol";

abstract contract AuthorizedCaller is AdminVerify {
    bytes32 public constant AUTHORIZED_CALLER = keccak256("AUTHORIZED_CALLER");

    modifier onlyAuthorizedCaller() {
        require(AccessControl.hasRole(AUTHORIZED_CALLER, _msgSender()), "Caller is not authorized");
        _;
    }

    function authorizeCaller(address _admin) public onlyAdmin {
        AccessControl.grantRole(AUTHORIZED_CALLER, _admin);
    }

    function revokeCallerAuthorization(address _admin) public onlyAdmin {
        AccessControl.revokeRole(AUTHORIZED_CALLER, _admin);
    }
}
