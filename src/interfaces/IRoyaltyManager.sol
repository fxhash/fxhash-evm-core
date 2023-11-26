// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {RoyaltyInfo} from "src/lib/Structs.sol";

/**
 * @title IRoyaltyManager
 * @author fx(hash)
 * @notice Extension for managing secondary royalties of FxGenArt721 tokens
 */
interface IRoyaltyManager {
    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when the royalties for a token ID have been updated
     * @param _tokenId ID of the token
     * @param _receiver Array of addresses receiving the royalties
     * @param _basisPoints Points used to calculate royalty payments (0.01s%)
     */
    event TokenIdRoyaltiesUpdated(uint256 indexed _tokenId, address _receiver, uint96 _basisPoints);

    /**
     * @notice Event emitted when the royalties for a list of receivers have been updated
     * @param _receivers Array of addresses receiving royalties
     * @param _allocations Array of allocations used to determine the proportional share of royalty payments
     * @param _basisPoints Points used to calculate royalty payments (0.01s%)
     */
    event TokenRoyaltiesUpdated(address[] _receivers, uint32[] _allocations, uint96 _basisPoints);

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
    function getRoyalties(uint256 _tokenId) external view returns (address[] memory, uint256[] memory);

    /**
     * @notice Returns the royalty information for a specific token ID and sale price
     * @param _tokenId ID of the token
     * @param _salePrice Sale price of the token
     * @return receiver Address receiving royalties
     * @return royaltyAmount Amount to royalties being paid out
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address, uint256);
}
