// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/*//////////////////////////////////////////////////////////////////////////
                                  STRUCTS
//////////////////////////////////////////////////////////////////////////*/

/**
 * @notice Struct of royalty information
 * @param receiver Address receiving royalties
 * @param basisPoints Points used to calculate the royalty payment (0.01%)
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
     * @notice Event emitted when the royalties for a token ID have been updated
     * @param tokenId ID of the token
     * @param receivers Array of addresses receiving the royalties
     * @param basisPoint Points used to calculate royalty payments (0.01s%)
     */
    event TokenIdRoyaltiesUpdated(uint256 indexed tokenId, address payable[] receivers, uint96[] basisPoint);

    /**
     * @notice Event emitted when the royalties for a list of receivers have been updated
     * @param receivers Array of addresses receiving royalties
     * @param basisPoints Array of points used to calculate royalty payments (0.01% per receiver)
     */
    event TokenRoyaltiesUpdated(address payable[] receivers, uint96[] basisPoints);

    /*//////////////////////////////////////////////////////////////////////////
                                  ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Error thrown when the royalties are not set
     */
    error BaseRoyaltiesNotSet();

    /**
     * @notice Error thrown when royalty configuration is greater than or equal to 100%
     */
    error InvalidRoyaltyConfig();

    /**
     * @notice Error thrown when array lengths do not match
     */
    error LengthMismatch();

    /**
     * @notice Error thrown when more than one royalty receiver is set
     */
    error MoreThanOneRoyaltyReceiver();

    /**
     * @notice Error thrown when the token ID does not exist
     */
    error NonExistentToken();

    /**
     * @notice Error thrown when royalty receiver is zero address
     */
    error NoRoyaltyReceiver();

    /**
     * @notice Error thrown when total basis points exceeds maximum value allowed
     */
    error OverMaxBasisPointsAllowed();

    /**
     * @notice Error thrown when the token royalties are not set
     */
    error TokenRoyaltiesNotSet();

    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Gets the royalties for a specific token ID
     * @param _tokenId ID of the token
     * @return Total receivers and basis points
     */
    function getRoyalties(uint256 _tokenId) external view returns (address payable[] memory, uint256[] memory);

    /**
     * @notice Returns the royalty information for a specific token ID and sale price
     * @param _tokenId ID of the token
     * @param _salePrice Sale price of the token
     * @return receiver Address receiving royalties
     * @return royaltyAmount Amount to royalties being paid out
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address, uint256);

    /**
     * @notice Sets the base royalties for all tokens
     * @param _receivers Array of addresses receiving royalties
     * @param _basisPoints Array of points used to calculate royalty payments (0.01% per receiver)
     */
    function setBaseRoyalties(address payable[] memory _receivers, uint96[] memory _basisPoints) external;

    /**
     * @notice Sets the royalties for a specific token ID
     * @param _tokenId ID of the token
     * @param _receivers Array of addresses receiving royalties
     * @param _basisPoints Array of points used to calculate royalty payments (0.01% per receiver)
     */
    function setTokenRoyalties(
        uint256 _tokenId,
        address payable[] memory _receivers,
        uint96[] memory _basisPoints
    ) external;
}
