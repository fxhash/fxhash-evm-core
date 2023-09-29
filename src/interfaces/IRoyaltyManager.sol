// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

struct RoyaltyInfo {
    address payable receiver;
    uint96 basisPoints;
}

interface IRoyaltyManager {
    /**
     * @notice Emitted when the royalties for a set of receivers have been updated.
     * @param receivers the addressaddress that will receive royalties.
     * @param basisPoints the basis points to calculate royalty payments(1/100th of a percent) for
     * each receiver
     */
    event TokenRoyaltiesUpdated(address payable[] receivers, uint96[] basisPoints);

    /**
     * @notice Emitted when the royalties for a specific token ID have been updated
     * @param tokenId The token ID for which the royalties have been updated
     * @param receivers The addresses that will receive royalties
     * @param basisPoint The basis points to calculate royalty payments (1/100th of a percent) for
     * each receiver
     */
    event TokenIdRoyaltiesUpdated(
        uint256 indexed tokenId, address payable[] receivers, uint96[] basisPoint
    );

    /// @notice Error thrown when the royalties are not set
    error BaseRoyaltiesNotSet();

    /// @notice Error thrown when royalty configuration is greater than or equal to 100% in terms of
    /// basisPoints
    error InvalidRoyaltyConfig();

    /// @notice Error thrown when there is a length mismatch between the receivers and basis points
    /// arrays
    error LengthMismatch();

    /// @notice Error thrown when more than one royalty receiver was set
    error MoreThanOneRoyaltyReceiver();

    /// @notice Error thrown when the token ID hasn't been minted
    error NonExistentToken();

    /// @notice Error thrown when no royalty receiver is provided
    error NoRoyaltyReceiver();

    /// @notice Error thrown when the basis points value exceeds the maximum allowed value
    error OverMaxBasisPointsAllowed();

    /// @notice Error thrown when the token royalties are not set
    error TokenRoyaltiesNotSet();

    function setBaseRoyalties(
        address payable[] memory receivers,
        uint96[] memory basisPoints
    ) external;

    function setTokenRoyalties(
        uint256 _tokenId,
        address payable[] memory receivers,
        uint96[] memory basisPoints
    ) external;

    function getRoyalties(uint256 tokenId)
        external
        view
        returns (address payable[] memory, uint256[] memory);

    function royaltyInfo(
        uint256 _tokenId,
        uint256 salePrice
    ) external view returns (address, uint256);
}
