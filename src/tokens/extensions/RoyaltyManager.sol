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
    function getRoyalties(
        uint256 _tokenId
    ) external view returns (address payable[] memory receivers, uint256[] memory basisPoints) {
        RoyaltyInfo[] storage tokenRoyalties_ = tokenRoyalties[_tokenId];
        uint256 baseLength = baseRoyalties.length;
        uint256 tokenLength = tokenRoyalties_.length;
        uint256 totalLength = baseLength + tokenLength;

        receivers = new address payable[](totalLength);
        basisPoints = new uint256[](totalLength);

        for (uint256 i; i < baseLength; ) {
            receivers[i] = baseRoyalties[i].receiver;
            basisPoints[i] = baseRoyalties[i].basisPoints;
            unchecked {
                ++i;
            }
        }

        unchecked {
            for (uint256 i; i < tokenLength; i++) {
                receivers[i + baseLength] = tokenRoyalties_[i].receiver;
                basisPoints[i + baseLength] = tokenRoyalties_[i].basisPoints;
            }
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
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IRoyaltyManager
     */
    function setBaseRoyalties(address payable[] calldata _receivers, uint96[] calldata _basisPoints) public {
        delete baseRoyalties;
        uint256 tokenLength = _basisPoints.length;
        if (_receivers.length != tokenLength) revert LengthMismatch();

        _checkRoyalties(_basisPoints, tokenLength);

        for (uint256 i; i < tokenLength; ) {
            baseRoyalties.push(RoyaltyInfo(_receivers[i], _basisPoints[i]));
            unchecked {
                ++i;
            }
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
        uint256 baseLength = baseRoyalties.length;
        uint96[] memory totalBasisPoints = new uint96[](baseLength + tokenLength);

        for (uint256 i; i < baseLength; ) {
            totalBasisPoints[i] = baseRoyalties[i].basisPoints;
            unchecked {
                ++i;
            }
        }

        unchecked {
            for (uint256 i; i < tokenLength; i++) {
                totalBasisPoints[i + baseLength] = _basisPoints[i];
            }
        }

        _checkRoyalties(totalBasisPoints, tokenLength);

        delete tokenRoyalties[_tokenId];
        RoyaltyInfo[] storage tokenRoyalties_ = tokenRoyalties[_tokenId];
        for (uint256 i; i < tokenLength; ) {
            tokenRoyalties_.push(RoyaltyInfo(_receivers[i], _basisPoints[i]));
            unchecked {
                ++i;
            }
        }

        emit TokenIdRoyaltiesUpdated(_tokenId, _receivers, _basisPoints);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Checks if the token ID exists
     */
    function _exists(uint256 _tokenId) internal view virtual returns (bool);

    /**
     * @dev Checks if the total basis points of royalties exceeds 10,000 (100%)
     */
    function _checkRoyalties(uint96[] memory _basisPoints, uint256 _length) internal pure {
        uint256 totalBasisPoints;
        unchecked {
            for (uint256 i; i < _length; i++) {
                if (_basisPoints[i] > MAX_ROYALTY_BPS) revert OverMaxBasisPointsAllowed();
                totalBasisPoints += _basisPoints[i];
            }
        }

        if (totalBasisPoints >= FEE_DENOMINATOR) revert InvalidRoyaltyConfig();
    }
}
