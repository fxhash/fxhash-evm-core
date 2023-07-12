// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IAllowMint} from "contracts/interfaces/IAllowMint.sol";
import {IModerationIssuer} from "contracts/interfaces/IModerationIssuer.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title AllowMint
/// @dev See the documentation in {IAllowMint}
contract AllowMint is IAllowMint, Ownable {
    /// @dev Address of Issuer Moderation contract
    address private issuerMod;

    /// @dev Initializes Issuer Moderation contract
    constructor(address _issuerMod) {
        issuerMod = _issuerMod;
    }

    /// @inheritdoc IAllowMint
    function updateIssuerModerationContract(address _moderationContract) external onlyOwner {
        issuerMod = _moderationContract;
    }

    /// @inheritdoc IAllowMint
    function isAllowed(address _tokenContract) external view returns (bool) {
        uint256 state = IModerationIssuer(issuerMod).issuerState(_tokenContract);
        if (state > 1) revert TokenModerated();
        return true;
    }
}
