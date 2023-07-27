// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IRoyaltyManager {
    struct RoyaltyInfo {
        address payable receiver;
        uint96 basisPoints;
    }

    error NoRoyaltyReceiver();
    error MoreThanOneRoyaltyReceiver();
    error RoyaltiesNotSet();
    error TokenRoyaltiesNotSet();
    error OverMaxBasisPointAllowed();
    error RoyaltiesAlreadySet();
    error LengthMismatch();
    error TokenRoyaltiesAlreadySet();

    /// @notice Royalty configuration is greater than or equal to 100% in terms of basisPoints
    error InvalidRoyaltyConfig();

    /// @notice Reverts if the token Id hasn't been minted
    error NonExistentToken();

    function deleteBaseRoyalty() external;

    function deleteTokenRoyalty(uint256 _tokenId) external;

    function setBaseRoyalties(
        address payable[] memory receivers,
        uint96[] memory basisPoints
    ) external;

    function setTokenRoyalties(
        uint256 _tokenId,
        address payable[] memory receivers,
        uint96[] memory basisPoints
    ) external;

    function getRoyalties(
        uint256 tokenId
    ) external view returns (address payable[] memory, uint256[] memory);
}
