// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IAllowMint} from "contracts/interfaces/IAllowMint.sol";
import {IModerationIssuer} from "contracts/interfaces/IModerationIssuer.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title AllowMint
/// @dev See the documentation in {IAllowMint}
contract AllowMint is IAllowMint, Ownable {
    /// @dev Address of Issuer Moderation contract
    address private issuerModeration;

    /// @dev Initializes Issuer Moderation contract
    constructor(address _issuerMod) {
        issuerModeration = _issuerMod;
    }

    /// @inheritdoc IAllowMint
    function updateIssuerModeration(address _moderation) external onlyOwner {
        issuerModeration = _moderation;
    }

    /// @inheritdoc IAllowMint
    function isAllowed(address _issuer) external view returns (bool) {
        (uint128 state, ) = IModerationIssuer(issuerModeration).issuers(_issuer);
        if (state > 1) revert TokenModerated();
        return true;
    }
}
