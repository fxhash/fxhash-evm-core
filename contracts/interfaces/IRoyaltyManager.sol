// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IRoyaltyManager {
    struct RoyaltyInfo {
        address payable receiver;
        uint96 basisPoints;
    }

    /// @notice Emitted when the royalties for a set of receivers have been updated.
    /// @param receivers the addressaddress that will receive royalties.
    /// @param basisPoints the basis points to calculate royalty payments(1/100th of a percent) for
    /// each receiver.
    event TokenRoyaltiesUpdated(address payable[] receivers, uint96[] basisPoints);
    /// @dev Emitted when the royalties for a specific token ID have been updated.
    /// @param tokenId The token ID for which the royalties have been updated.
    /// @param receivers The addresses that will receive royalties.
    /// @param basisPoint The basis points to calculate royalty payments (1/100th of a percent) for each receiver.
    event TokenIdRoyaltiesUpdated(
        uint256 indexed tokenId,
        address payable[] receivers,
        uint96[] basisPoint
    );

    /// @dev Throws an error if no royalty receiver is provided.
    error NoRoyaltyReceiver();

    /// @dev Throws an error if more than one royalty receiver was set .
    error MoreThanOneRoyaltyReceiver();

    /// @dev Throws an error if the royalties are not set.
    error BaseRoyaltiesNotSet();

    /// @dev Throws an error if the token royalties are not set.
    error TokenRoyaltiesNotSet();

    /// @dev Throws an error if the basis point value exceeds the maximum allowed value.
    error OverMaxBasisPointAllowed();

    /// @dev Throws an error if the royalties are already set.
    error BaseRoyaltiesAlreadySet();

    /// @dev Throws an error if there is a length mismatch between the receivers and basis points arrays.
    error LengthMismatch();

    /// @dev Throws an error if the token royalties are already set.
    error TokenRoyaltiesAlreadySet();

    /// @notice Royalty configuration is greater than or equal to 100% in terms of basisPoints
    error InvalidRoyaltyConfig();

    /// @notice Reverts if the token Id hasn't been minted
    error NonExistentToken();

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
