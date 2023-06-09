// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "contracts/libs/lib-admin/LibAdmin.sol";

contract PricingFixed is AccessControl {
    struct PriceDetails {
        uint256 price;
        uint256 opensAt;
    }

    mapping(uint256 => PriceDetails) pricings;

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

    modifier onlyFxHashAdmin() {
        require(
            AccessControl.hasRole(LibAdmin.FXHASH_ADMIN, _msgSender()),
            "Caller is not a FxHash admin"
        );
        _;
    }
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, address(bytes20(_msgSender())));
        _setupRole(LibAdmin.FXHASH_ADMIN, address(bytes20(_msgSender())));
    }

    // Function to grant the ADMIN_ROLE to an address
    function grantAdminRole(address _admin) public onlyAdmin {
        AccessControl.grantRole(AccessControl.DEFAULT_ADMIN_ROLE, _admin);
    }

    // Function to revoke the ADMIN_ROLE from an address
    function revokeAdminRole(address _admin) public onlyAdmin {
        AccessControl.revokeRole(AccessControl.DEFAULT_ADMIN_ROLE, _admin);
    }

    function grantFxHashAdminRole(address _admin) public onlyAdmin {
        AccessControl.grantRole(LibAdmin.FXHASH_ADMIN, _admin);
    }

    function revokeFxHashAdminRole(address _admin) public onlyAdmin {
        AccessControl.revokeRole(LibAdmin.FXHASH_ADMIN, _admin);
    }

    function setPrice(
        uint256 issuerId,
        bytes memory details
    ) external onlyFxHashAdmin {
        PriceDetails memory pricingDetails = abi.decode(
            details,
            (PriceDetails)
        );
        require(pricingDetails.price > 0, "price <= 0");
        require(pricingDetails.opensAt > 0, "opensAt <= 0");
        pricings[issuerId] = pricingDetails;
    }

    function getPrice(
        uint256 issuerId,
        uint256 timestamp
    ) external view returns (uint256) {
        PriceDetails memory pricing = pricings[issuerId];
        require(pricing.price > 0, "PRICING_NO_ISSUER");

        if (pricing.opensAt > 0) {
            require(timestamp >= pricing.opensAt, "NOT_OPENED_YET");
        }

        return pricing.price;
    }
}
