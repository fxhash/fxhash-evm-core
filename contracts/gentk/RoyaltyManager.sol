// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IRoyaltyManager} from "contracts/interfaces/IRoyaltyManager.sol";

/// @title RoyaltyManager
/// @notice A contract for managing royalties
abstract contract RoyaltyManager is IRoyaltyManager {
    uint256 public constant MAX_ROYALTY = 2500;
    /// @notice A struct containing basisPoints and receiver address for a royalty
    RoyaltyInfo[] public royalties;

    /// @dev Mapping of token IDs to token-specific royalties
    mapping(uint256 => RoyaltyInfo[]) private royaltyTokenInfo;

    /**
     * @notice Sets the base royalties for the contract
     * @param _receivers The addresses that will receive royalties.
     * @param _basisPoints The basis points to calculate royalty payments (1/100th of a percent) for each receiver.
     */
    function setBaseRoyalties(
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints
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
     * @dev Gets the royalty information for a given token ID and sale price
     * @param _tokenId The token ID for which the royalty information is being retrieved.
     * @param _salePrice The sale price of the token.
     * @return _receiver The address that will receive the royalty payment.
     * @return _amount The amount of royalty payment in wei.
     */
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view virtual returns (address _receiver, uint256 _amount) {
        RoyaltyInfo[] memory tokenRoyalties = royaltyTokenInfo[_tokenId];
        RoyaltyInfo[] memory royalties_ = royalties;

        if (tokenRoyalties.length + royalties.length > 1) revert MoreThanOneRoyaltyReceiver();
        /// return early
        if (tokenRoyalties.length + royalties.length == 0) return (address(0), 0);
        uint96 basisPoints;
        (_receiver, basisPoints) = tokenRoyalties.length > 0
            ? (tokenRoyalties[0].receiver, tokenRoyalties[0].basisPoints)
            : (royalties_[0].receiver, royalties_[0].basisPoints);
        _amount = (_salePrice * basisPoints) / _feeDenominator();
    }

    /**
     * @dev Gets the royalty information for a given token ID
     * @param _tokenId The token ID for which the royalty information is being retrieved.
     * @return _allReceivers The addresses that will receive royalties.
     * @return _allBasisPoints The basis points to calculate royalty payments (1/100th of a percent) for each receiver.
     */
    function getRoyalties(
        uint256 _tokenId
    )
        external
        view
        returns (address payable[] memory _allReceivers, uint256[] memory _allBasisPoints)
    {
        RoyaltyInfo[] memory tokenRoyalties = royaltyTokenInfo[_tokenId];
        RoyaltyInfo[] memory royalties_ = royalties;
        uint256 baseLength = royalties_.length;
        uint256 tokenLength = tokenRoyalties.length;
        uint256 length = baseLength + tokenLength;
        _allReceivers = new address payable[](length);
        _allBasisPoints = new uint256[](length);
        for (uint256 i; i < baseLength; i++) {
            _allReceivers[i] = royalties_[i].receiver;
            _allBasisPoints[i] = royalties_[i].basisPoints;
        }

        for (uint256 i; i < tokenLength; i++) {
            _allReceivers[i + baseLength] = tokenRoyalties[i].receiver;
            _allBasisPoints[i + baseLength] = tokenRoyalties[i].basisPoints;
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
        delete royaltyTokenInfo[_tokenId];
        RoyaltyInfo[] storage tokenRoyalties = royaltyTokenInfo[_tokenId];
        RoyaltyInfo[] memory royalties_ = royalties;
        uint256 baseLength = royalties.length;
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
            tokenRoyalties.push(RoyaltyInfo(_receivers[i], _basisPoints[i]));
        }
    }

    /**
     * @dev Sets the base royalties for the contract
     * @param _receivers The addresses that will receive royalties.
     * @param _basisPoints The basis points to calculate royalty payments (1/100th of a percent) for each receiver.
     */
    function _setBaseRoyalties(
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints
    ) internal {
        delete royalties;
        if (_receivers.length != _basisPoints.length) revert LengthMismatch();
        _checkRoyalties(_basisPoints);
        for (uint256 i; i < _basisPoints.length; i++) {
            royalties.push(RoyaltyInfo(_receivers[i], _basisPoints[i]));
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
