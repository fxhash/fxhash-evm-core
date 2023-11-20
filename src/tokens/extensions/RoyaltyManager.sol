// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IRoyaltyManager, RoyaltyInfo} from "src/interfaces/IRoyaltyManager.sol";
import {FEE_DENOMINATOR, MAX_ROYALTY_BPS} from "src/utils/Constants.sol";

/**
 * @title RoyaltyManager
 * @author fx(hash)
 * @notice See the documentation in {IRoyaltyManager}
 */
abstract contract RoyaltyManager is IRoyaltyManager {
    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns royalty information of index in array list
     */
    RoyaltyInfo[] public baseRoyalties;

    /**
     * @notice Mapping of token ID to array of royalty information
     */
    mapping(uint256 => RoyaltyInfo[]) public tokenRoyalties;

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IRoyaltyManager
     */
    function getRoyalties(
        uint256 _tokenId
    ) external view returns (address[] memory receivers, uint256[] memory basisPoints) {
        RoyaltyInfo[] storage tokenRoyalties_ = tokenRoyalties[_tokenId];
        uint256 baseLength = baseRoyalties.length;
        uint256 tokenLength = tokenRoyalties_.length;
        uint256 totalLength = baseLength + tokenLength;

        receivers = new address[](totalLength);
        basisPoints = new uint256[](totalLength);

        for (uint256 i; i < baseLength; ++i) {
            receivers[i] = baseRoyalties[i].receiver;
            basisPoints[i] = baseRoyalties[i].basisPoints;
        }

        for (uint256 i; i < tokenLength; ++i) {
            receivers[i + baseLength] = tokenRoyalties_[i].receiver;
            basisPoints[i + baseLength] = tokenRoyalties_[i].basisPoints;
        }
    }

    /**
     * @inheritdoc IRoyaltyManager
     */
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (address receiver, uint256 amount) {
        RoyaltyInfo[] storage tokenRoyalties_ = tokenRoyalties[_tokenId];
        uint256 baseLength = baseRoyalties.length;
        uint256 tokenLength = tokenRoyalties_.length;
        if (tokenLength + baseLength > 1) revert MoreThanOneRoyaltyReceiver();
        if (tokenLength + baseLength == 0) return (receiver, amount);

        uint96 basisPoints;
        (receiver, basisPoints) = tokenRoyalties_.length > 0
            ? (tokenRoyalties_[0].receiver, tokenRoyalties_[0].basisPoints)
            : (baseRoyalties[0].receiver, baseRoyalties[0].basisPoints);
        amount = (_salePrice * basisPoints) / FEE_DENOMINATOR;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Sets the base royalties for all tokens
     * @param _receivers Array of addresses receiving royalties
     * @param _basisPoints Array of points used to calculate royalty payments (0.01% per receiver)
     */
    function _setBaseRoyalties(address[] calldata _receivers, uint96[] calldata _basisPoints) internal {
        delete baseRoyalties;
        uint256 tokenLength = _basisPoints.length;
        if (_receivers.length != tokenLength) revert LengthMismatch();

        _checkRoyalties(_basisPoints, tokenLength);

        for (uint256 i; i < tokenLength; ++i) {
            baseRoyalties.push(RoyaltyInfo(_receivers[i], _basisPoints[i]));
        }

        emit TokenRoyaltiesUpdated(_receivers, _basisPoints);
    }

    /**
     * @notice Sets the royalties for a specific token ID
     * @param _tokenId ID of the token
     * @param _receivers Array of addresses receiving royalties
     * @param _basisPoints Array of points used to calculate royalty payments (0.01% per receiver)
     */
    function _setTokenRoyalties(
        uint256 _tokenId,
        address[] calldata _receivers,
        uint96[] calldata _basisPoints
    ) internal {
        if (!_exists(_tokenId)) revert NonExistentToken();
        uint256 tokenLength = _basisPoints.length;
        if (_receivers.length != tokenLength) revert LengthMismatch();
        uint256 baseLength = baseRoyalties.length;
        uint96[] memory totalBasisPoints = new uint96[](baseLength + tokenLength);

        for (uint256 i; i < baseLength; ++i) {
            totalBasisPoints[i] = baseRoyalties[i].basisPoints;
        }

        for (uint256 i; i < tokenLength; ++i) {
            totalBasisPoints[i + baseLength] = _basisPoints[i];
        }

        _checkRoyalties(totalBasisPoints, tokenLength);

        delete tokenRoyalties[_tokenId];
        RoyaltyInfo[] storage tokenRoyalties_ = tokenRoyalties[_tokenId];
        for (uint256 i; i < tokenLength; ++i) {
            tokenRoyalties_.push(RoyaltyInfo(_receivers[i], _basisPoints[i]));
        }

        emit TokenIdRoyaltiesUpdated(_tokenId, _receivers, _basisPoints);
    }

    /**
     * @dev Checks if the token ID exists
     */
    function _exists(uint256 _tokenId) internal view virtual returns (bool);

    /**
     * @dev Checks if the total basis points of royalties exceeds 10,000 (100%)
     */
    function _checkRoyalties(uint96[] memory _basisPoints, uint256 _length) internal pure {
        uint256 totalBasisPoints;
        for (uint256 i; i < _length; ++i) {
            if (_basisPoints[i] > MAX_ROYALTY_BPS) revert OverMaxBasisPointsAllowed();
            totalBasisPoints += _basisPoints[i];
        }

        if (totalBasisPoints >= FEE_DENOMINATOR) revert InvalidRoyaltyConfig();
    }
}
