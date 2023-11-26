// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IRoyaltyManager, RoyaltyInfo} from "src/interfaces/IRoyaltyManager.sol";
import {FEE_DENOMINATOR, MAX_ROYALTY_BPS} from "src/utils/Constants.sol";
import {SPLITS_MAIN} from "script/utils/Constants.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";

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
    RoyaltyInfo public baseRoyalties;

    /**
     * @notice Mapping of token ID to array of royalty information
     */
    mapping(uint256 => RoyaltyInfo) public tokenRoyalties;

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IRoyaltyManager
     */
    function getRoyalties(
        uint256 _tokenId
    ) external view returns (address[] memory receivers, uint256[] memory basisPoints) {
        RoyaltyInfo storage tokenRoyalties_ = tokenRoyalties[_tokenId];
        if (tokenRoyalties_.receiver != address(0) && tokenRoyalties_.basisPoints != uint96(0)) {
            receivers = new address[](2);
            basisPoints = new uint256[](2);
            receivers[1] = tokenRoyalties_.receiver;
            basisPoints[1] = tokenRoyalties_.basisPoints;
        } else {
            receivers = new address[](1);
            basisPoints = new uint256[](1);
        }
        receivers[0] = baseRoyalties.receiver;
        basisPoints[0] = baseRoyalties.basisPoints;
    }

    /**
     * @inheritdoc IRoyaltyManager
     */
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (address receiver, uint256 amount) {
        RoyaltyInfo storage tokenRoyalties_ = tokenRoyalties[_tokenId];
        if (tokenRoyalties_.receiver != address(0) && tokenRoyalties_.basisPoints != uint96(0)) {
            revert MoreThanOneRoyaltyReceiver();
        } else if (baseRoyalties.receiver == address(0) && baseRoyalties.basisPoints == uint96(0)) {
            return (receiver, amount);
        } else {
            receiver = baseRoyalties.receiver;
            amount = (_salePrice * baseRoyalties.basisPoints) / FEE_DENOMINATOR;
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Sets the base royalties for all tokens
     * @param _receivers Array of addresses receiving royalties
     * @param _allocations Array of allocations used to calculate royalty payments
     * @param _basisPoints basis points used to calculate the royalty payment
     */
    function _setBaseRoyalties(
        address[] calldata _receivers,
        uint32[] calldata _allocations,
        uint96 _basisPoints
    ) internal {
        _checkRoyalties(_receivers, _allocations, _basisPoints);
        /// compute split if necessary
        address receiver;
        if (_receivers.length == 0 || _basisPoints == 0) {
            delete baseRoyalties;
        } else if (_receivers.length > 1) {
            receiver = ISplitsMain(SPLITS_MAIN).predictImmutableSplitAddress(_receivers, _allocations, 0);
        } else {
            receiver = _receivers[0];
        }
        baseRoyalties = RoyaltyInfo(receiver, _basisPoints);
        emit TokenRoyaltiesUpdated(_receivers, _allocations, _basisPoints);
    }

    /**
     * @notice Sets the royalties for a specific token ID
     * @param _tokenId ID of the token
     * @param _receiver the address receiving royalty payments
     * @param _basisPoints Array of points used to calculate royalty payments (0.01% per receiver)
     */
    function _setTokenRoyalties(uint256 _tokenId, address _receiver, uint96 _basisPoints) internal {
        if (!_exists(_tokenId)) revert NonExistentToken();
        if (_basisPoints > MAX_ROYALTY_BPS) revert OverMaxBasisPointsAllowed();
        if (baseRoyalties.basisPoints + _basisPoints >= FEE_DENOMINATOR) revert InvalidRoyaltyConfig();
        tokenRoyalties[_tokenId] = RoyaltyInfo(_receiver, _basisPoints);
        emit TokenIdRoyaltiesUpdated(_tokenId, _receiver, _basisPoints);
    }

    /**
     * @dev Checks if the token ID exists
     */
    function _exists(uint256 _tokenId) internal view virtual returns (bool);

    /**
     * @dev Checks if:
     *        1. the total basis points of royalties exceeds 10,000 (100%)
     *        2. A single receiver exceeds 25,000 (25%)
     */
    function _checkRoyalties(
        address[] memory _receivers,
        uint32[] memory _allocations,
        uint96 _basisPoints
    ) internal pure {
        uint256 allocationsLength = _allocations.length;
        if (_receivers.length != allocationsLength) revert LengthMismatch();
        if (_basisPoints >= FEE_DENOMINATOR) revert InvalidRoyaltyConfig();
        for (uint256 i; i < allocationsLength; ++i) {
            if ((_allocations[i] * _basisPoints) / 10e6 > MAX_ROYALTY_BPS) revert OverMaxBasisPointsAllowed();
        }
    }
}
