// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @title IAllowMint
 * @notice Checks allowance state of token moderation
 */
interface IAllowMint {
    /// @notice Thrown when moderation state is greater than 1
    error TokenModerated();

    /**
     * @notice Updates the Issuer Moderation contract
     * @param _moderationContract Address of new moderation contract
     */
    function updateIssuerModerationContract(address _moderationContract) external;

    /**
     * @notice Returns true of false depending on the availability to mint an
     * iteration given rules defined by the implementation.
     * @param _tokenContract Address of moderation contract
     * @return allowed is the mint allowed
     */
    function isAllowed(address _tokenContract) external view returns (bool);
}
