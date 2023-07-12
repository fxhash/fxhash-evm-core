// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IAllowMint} from "contracts/interfaces/IAllowMint.sol";
import {IModerationIssuer} from "contracts/interfaces/IModerationIssuer.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title AllowMint
/// @notice Checks allowance of token moderation
contract AllowMint is IAllowMint, Ownable {
    /// @notice Address of Issuer Moderation contract
    address issuerMod;

    /// @dev Initializes Issuer Moderation contract
    constructor(address _issuerMod) {
        issuerMod = _issuerMod;
    }

    /// @notice Updates the Issuer Moderation contract
    /// @param _contract Address of new moderation contract
    function updateIssuerModerationContract(address _contract) external onlyOwner {
        issuerMod = _contract;
    }

    /// @notice Gets the state from the token moderation contract
    /// @param _tokenContract Address of moderation contract
    /// @return boolean value of allowance
    function isAllowed(address _tokenContract) external view returns (bool) {
        uint256 state = IModerationIssuer(issuerMod).issuerState(_tokenContract);
        if (state > 1) revert TokenModerated();
        return true;
    }
}
