// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

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
     * @notice Returns royalty information of index in array
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

    /**
     * @inheritdoc IRoyaltyManager
     */
    function getRoyalties(
        uint256 _tokenId
    ) external view returns (address payable[] memory receivers, uint256[] memory basisPoints) {
        RoyaltyInfo[] storage tokenRoyalties_ = tokenRoyalties[_tokenId];
        uint256 baseLength = baseRoyalties.length;
        uint256 tokenLength = tokenRoyalties_.length;
        uint256 totalLength = baseLength + tokenLength;

        receivers = new address payable[](totalLength);
        basisPoints = new uint256[](totalLength);

        for (uint256 i; i < baseLength; i++) {
            receivers[i] = baseRoyalties[i].receiver;
            basisPoints[i] = baseRoyalties[i].basisPoints;
        }

        for (uint256 i; i < tokenLength; i++) {
            receivers[i + baseLength] = tokenRoyalties_[i].receiver;
            basisPoints[i + baseLength] = tokenRoyalties_[i].basisPoints;
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IRoyaltyManager
     */
    function setBaseRoyalties(address payable[] calldata _receivers, uint96[] calldata _basisPoints) public {
        delete baseRoyalties;
        uint256 tokenLength = _basisPoints.length;
        if (_receivers.length != tokenLength) revert LengthMismatch();

        _checkRoyalties(_basisPoints);

        for (uint256 i; i < tokenLength; i++) {
            baseRoyalties.push(RoyaltyInfo(_receivers[i], _basisPoints[i]));
        }

        emit TokenRoyaltiesUpdated(_receivers, _basisPoints);
    }

    /**
     * @inheritdoc IRoyaltyManager
     */
    function setTokenRoyalties(
        uint256 _tokenId,
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints
    ) public {
        if (!_exists(_tokenId)) revert NonExistentToken();
        uint256 tokenLength = _basisPoints.length;
        if (_receivers.length != tokenLength) revert LengthMismatch();

        delete tokenRoyalties[_tokenId];
        RoyaltyInfo[] storage tokenRoyalties_ = tokenRoyalties[_tokenId];
        uint256 baseLength = baseRoyalties.length;
        uint96[] memory totalBasisPoints = new uint96[](baseLength + tokenLength);

        for (uint256 i; i < baseLength; i++) {
            totalBasisPoints[i] = baseRoyalties[i].basisPoints;
        }

        for (uint256 i; i < tokenLength; i++) {
            totalBasisPoints[i + baseLength] = _basisPoints[i];
        }

        _checkRoyalties(totalBasisPoints);

        for (uint256 i; i < _basisPoints.length; i++) {
            tokenRoyalties_.push(RoyaltyInfo(_receivers[i], _basisPoints[i]));
        }

        emit TokenIdRoyaltiesUpdated(_tokenId, _receivers, _basisPoints);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Checks if given token ID exists
     */
    function _exists(uint256 _tokenId) internal view virtual returns (bool);

    /**
     * @dev Checks if total basis points of royalties exceeds 10,000 (100%)
     */
    function _checkRoyalties(uint96[] memory _basisPoints) internal pure {
        uint256 totalBasisPoints;
        for (uint256 i; i < _basisPoints.length; i++) {
            if (_basisPoints[i] > MAX_ROYALTY_BPS) revert OverMaxBasisPointsAllowed();
            totalBasisPoints += _basisPoints[i];
        }
        if (totalBasisPoints >= FEE_DENOMINATOR) revert InvalidRoyaltyConfig();
    }
}
