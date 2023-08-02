// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IRoyaltyManager, RoyaltyInfo} from "contracts/interfaces/IRoyaltyManager.sol";

/// @title RoyaltyManager
/// @notice A contract for managing royalties
abstract contract RoyaltyManager is IRoyaltyManager {
    uint256 public constant MAX_ROYALTY = 2500;
    /// @notice A struct containing basisPoints and receiver address for a royalty
    RoyaltyInfo[] public baseRoyalties;

    /// @dev Mapping of token IDs to token-specific royalties
    mapping(uint256 => RoyaltyInfo[]) public tokenRoyalties;

    /**
     * @notice Sets the base royalties for the contract
     * @param _receivers The addresses that will receive royalties.
     * @param _basisPoints The basis points to calculate royalty payments (1/100th of a percent) for each receiver.
     */
    function setBaseRoyalties(
        address payable[] memory _receivers,
        uint96[] memory _basisPoints
    ) external virtual {
        _setBaseRoyalties(_receivers, _basisPoints);
        emit TokenRoyaltiesUpdated(_receivers, _basisPoints);
    }

    /**
     * @notice Sets the token-specific royalties for a given token ID
     * @param _tokenId The token ID for which the royalties are being set.
     * @param _receivers The addresses that will receive royalties.
     * @param _basisPoints The basis points to calculate royalty payments (1/100th of a percent) for each receiver.
     */
    function setTokenRoyalties(
        uint256 _tokenId,
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints
    ) external virtual {
        _setTokenRoyalties(_tokenId, _receivers, _basisPoints);
        emit TokenIdRoyaltiesUpdated(_tokenId, _receivers, _basisPoints);
    }

    /**
     * @notice Gets the royalty information for a given token ID and sale price
     * @param _tokenId The token ID for which the royalty information is being retrieved.
     * @param _salePrice The sale price of the token.
     * @return receiver The address that will receive the royalty payment.
     * @return amount The amount of royalty payment in wei.
     */
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view virtual returns (address receiver, uint256 amount) {
        RoyaltyInfo[] storage tokenRoyalties_ = tokenRoyalties[_tokenId];
        RoyaltyInfo[] storage baseRoyalties_ = baseRoyalties;

        if (tokenRoyalties_.length + baseRoyalties.length > 1) revert MoreThanOneRoyaltyReceiver();
        /// return early
        if (tokenRoyalties_.length + baseRoyalties.length == 0) return (receiver, amount);
        uint96 basisPoints;
        (receiver, basisPoints) = tokenRoyalties_.length > 0
            ? (tokenRoyalties_[0].receiver, tokenRoyalties_[0].basisPoints)
            : (baseRoyalties_[0].receiver, baseRoyalties_[0].basisPoints);
        amount = (_salePrice * basisPoints) / _feeDenominator();
    }

    /**
     * @notice Gets the royalty information for a given token ID
     * @param _tokenId The token ID for which the royalty information is being retrieved.
     * @return allReceivers The addresses that will receive royalties.
     * @return allBasisPoints The basis points to calculate royalty payments (1/100th of a percent) for each receiver.
     */
    function getRoyalties(
        uint256 _tokenId
    )
        external
        view
        returns (address payable[] memory allReceivers, uint256[] memory allBasisPoints)
    {
        RoyaltyInfo[] storage tokenRoyalties_ = tokenRoyalties[_tokenId];
        RoyaltyInfo[] storage royalties_ = baseRoyalties;
        uint256 baseLength = royalties_.length;
        uint256 tokenLength = tokenRoyalties_.length;
        uint256 length = baseLength + tokenLength;
        allReceivers = new address payable[](length);
        allBasisPoints = new uint256[](length);
        for (uint256 i; i < baseLength; i++) {
            allReceivers[i] = royalties_[i].receiver;
            allBasisPoints[i] = royalties_[i].basisPoints;
        }

        for (uint256 i; i < tokenLength; i++) {
            allReceivers[i + baseLength] = tokenRoyalties_[i].receiver;
            allBasisPoints[i + baseLength] = tokenRoyalties_[i].basisPoints;
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool);

    /**
     * @dev Sets the token-specific royalties for a given token ID
     * @param _tokenId The token ID for which the royalties are being set.
     * @param _receivers The addresses that will receive royalties.
     * @param _basisPoints The basis points to calculate royalty payments (1/100th of a percent) for each receiver.
     */
    function _setTokenRoyalties(
        uint256 _tokenId,
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints
    ) internal virtual {
        if (!_exists(_tokenId)) revert NonExistentToken();
        if (_receivers.length != _basisPoints.length) revert LengthMismatch();
        /// Deleting first, so this could be used to reset royalties to a new config
        delete tokenRoyalties[_tokenId];
        RoyaltyInfo[] storage tokenRoyalties_ = tokenRoyalties[_tokenId];
        RoyaltyInfo[] memory royalties_ = baseRoyalties;
        uint256 baseLength = baseRoyalties.length;
        uint256 tokenLength = _basisPoints.length;
        uint96[] memory totalBasisPoints = new uint96[](baseLength + _basisPoints.length);
        for (uint256 i; i < baseLength; i++) {
            totalBasisPoints[i] = royalties_[i].basisPoints;
        }

        for (uint256 i; i < tokenLength; i++) {
            totalBasisPoints[i + baseLength] = _basisPoints[i];
        }

        _checkRoyalties(totalBasisPoints);

        for (uint256 i; i < _basisPoints.length; i++) {
            tokenRoyalties_.push(RoyaltyInfo(_receivers[i], _basisPoints[i]));
        }
    }

    /**
     * @dev Sets the base royalties for the contract
     * @param _receivers The addresses that will receive royalties.
     * @param _basisPoints The basis points to calculate royalty payments (1/100th of a percent) for each receiver.
     */
    function _setBaseRoyalties(
        address payable[] memory _receivers,
        uint96[] memory _basisPoints
    ) internal {
        delete baseRoyalties;
        if (_receivers.length != _basisPoints.length) revert LengthMismatch();
        _checkRoyalties(_basisPoints);
        for (uint256 i; i < _basisPoints.length; i++) {
            baseRoyalties.push(RoyaltyInfo(_receivers[i], _basisPoints[i]));
        }
        emit TokenRoyaltiesUpdated(_receivers, _basisPoints);
    }

    function _exists(uint256) internal virtual returns (bool);

    /**
     * @dev Returns the fee denominator for calculating royalty amounts.
     * @return The fee denominator.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    /**
     * @dev Checks that the total basis points for the royalties do not exceed 10000 (100%)
     */
    function _checkRoyalties(uint96[] memory _basisPoints) internal pure {
        uint256 totalBasisPoints;
        for (uint256 i; i < _basisPoints.length; i++) {
            if (_basisPoints[i] > MAX_ROYALTY) revert OverMaxBasisPointAllowed();
            totalBasisPoints += _basisPoints[i];
        }
        if (totalBasisPoints >= _feeDenominator()) revert InvalidRoyaltyConfig();
    }
}
