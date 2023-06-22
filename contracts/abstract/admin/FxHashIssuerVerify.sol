// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "contracts/abstract/admin/FxHashAdminVerify.sol";
import "contracts/interfaces/IIssuerToken.sol";

abstract contract FxHashIssuerVerify is FxHashAdminVerify {
    bytes32 public constant FXHASH_ISSUER = keccak256("FXHASH_ISSUER");

    modifier onlyFxHashIssuer() {
        require(
            AccessControl.hasRole(FXHASH_ISSUER, _msgSender()),
            "Caller is not a FxHash issuer"
        );
        _;
    }

    function grantFxHashIssuerRole(address _issuer) public onlyAdmin {
        require(
            IERC165(_issuer).supportsInterface(type(IIssuerToken).interfaceId),
            "Contract does not support IIssuerToken interface."
        );
        AccessControl.grantRole(FXHASH_ISSUER, _issuer);
    }

    function revokeFxHashIssuerRole(address _issuer) public onlyAdmin {
        AccessControl.revokeRole(FXHASH_ISSUER, _issuer);
    }
}
