// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/*//////////////////////////////////////////////////////////////////////////
                                  STRUCTS
//////////////////////////////////////////////////////////////////////////*/

/**
 * @notice Struct to store the info for a royalty recipient
 * @param The address that will receive the royalty payment
 * @param The basis points to calculate the royalty payment (1/100th of a percent)
 */
struct RoyaltyInfo {
    address payable receiver;
    uint96 basisPoints;
}

/**
 * @title IRoyaltyManager
 * @author fx(hash)
 * @notice Extension that manages secondary royalties of FxGenArt721 tokens
 */
interface IRoyaltyManager {
    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

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
    event TokenIdRoyaltiesUpdated(uint256 indexed tokenId, address payable[] receivers, uint96[] basisPoint);

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

    /**
     * @notice Sets the base royalties for all tokens
     * @param receivers The addresses that will receive royalties
     * @param basisPoints The basis points to calculate royalty payments (1/100th of a percent) for each receiver
     */
    function setBaseRoyalties(address payable[] memory receivers, uint96[] memory basisPoints) external;

    /**
     * @notice Sets the royalties for a specific token ID
     * @param _tokenId The token ID for which the royalties are being set
     * @param _receivers The addresses that will receive royalties
     * @param _basisPoints The basis points to calculate royalty payments (1/100th of a percent) for each receiver
     */
    function setTokenRoyalties(
        uint256 _tokenId,
        address payable[] memory _receivers,
        uint96[] memory _basisPoints
    ) external;

    /**
     * @notice Retrieves the royalties for a specific token ID
     * @param _tokenId The token ID for which the royalties are being retrieved
     * @return receivers The addresses that will receive royalties
     * @return basisPoints The basis points to calculate royalty payments (1/100th of a percent) for each receiver
     */
    function getRoyalties(uint256 _tokenId) external view returns (address payable[] memory, uint256[] memory);

    /**
     * @notice Retrieves the royalty information for a specific token ID and sale price
     * @param _tokenId The token ID for which the royalty information is being retrieved
     * @param _salePrice The sale price of the token
     * @return receiver The address that will receive the royalty payment
     * @return royaltyAmount The royalty amount to be paid to the receiver
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address, uint256);
}
