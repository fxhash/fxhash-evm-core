// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IRoyaltyManager} from "contracts/interfaces/IRoyaltyManager.sol";
import {IERC2981Upgradeable} from "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";

abstract contract RoyaltyManager is IRoyaltyManager, IERC2981Upgradeable {
    /// @notice A struct containing basisPoints and receiver address for a royalty
    RoyaltyInfo[] public royalties;

    mapping(uint256 => RoyaltyInfo[]) public royaltyTokenInfo;

    /// @notice Emitted when the royalties for a set of receivers have been updated.
    /// @param receivers the addressaddress that will receive royalties.
    /// @param basisPoints the basis points to calculate royalty payments(1/100th of a percent) for
    /// each receiver.
    event TokenRoyaltiesUpdated(address payable[] receivers, uint96[] basisPoints);
    event TokenIdRoyaltiesUpdated(
        uint256 indexed tokenId,
        address payable[] receivers,
        uint96[] basisPoint
    );

    /**
     * @dev Sets the royalties for the contract
     */
    function setBaseRoyalties(
        address payable[] memory receivers,
        uint96[] memory basisPoints
    ) external virtual {
        _setBaseRoyalties(receivers, basisPoints);
        emit TokenRoyaltiesUpdated(receivers, basisPoints);
    }

    function setTokenRoyalties(
        uint256 _tokenId,
        address payable[] memory receivers,
        uint96[] memory basisPoints
    ) external virtual {
        _setTokenRoyalties(_tokenId, receivers, basisPoints);
        emit TokenIdRoyaltiesUpdated(_tokenId, receivers, basisPoints);
    }

    function royaltyInfo(
        uint256 _tokenId,
        uint256 salePrice
    ) external view virtual returns (address, uint256) {
        RoyaltyInfo[] storage tokenRoyalties = royaltyTokenInfo[_tokenId];
        RoyaltyInfo[] memory royalties_ = royalties;

        if (tokenRoyalties.length + royalties.length > 1) revert MoreThanOneRoyaltyReceiver();
        if (tokenRoyalties.length + royalties.length == 0) revert NoRoyaltyReceiver();
        (address receiver, uint96 basisPoints) = tokenRoyalties.length > 0
            ? (tokenRoyalties[0].receiver, tokenRoyalties[0].basisPoints)
            : (royalties_[0].receiver, royalties_[0].basisPoints);
        uint256 amount = (salePrice * basisPoints) / _feeDenominator();
        return (receiver, amount);
    }

    function getRoyalties(
        uint256 _tokenId
    ) external view returns (address payable[] memory, uint256[] memory) {
        RoyaltyInfo[] storage tokenRoyalties = royaltyTokenInfo[_tokenId];
        RoyaltyInfo[] memory royalties_ = royalties;
        uint256 baseLength = royalties_.length;
        uint256 tokenLength = tokenRoyalties.length;
        uint256 length = baseLength + tokenLength;
        address payable[] memory allReceivers = new address payable[](length);
        uint256[] memory allBasisPoints = new uint256[](length);
        for (uint256 i; i < baseLength; i++) {
            allReceivers[i] = royalties_[i].receiver;
            allBasisPoints[i] = royalties_[i].basisPoints;
        }

        for (uint256 i; i < tokenLength; i++) {
            allReceivers[i + baseLength] = tokenRoyalties[i].receiver;
            allBasisPoints[i + baseLength] = tokenRoyalties[i].basisPoints;
        }
        return (allReceivers, allBasisPoints);
    }

    function _setTokenRoyalties(
        uint256 _tokenId,
        address payable[] memory receivers,
        uint96[] memory basisPoints
    ) internal virtual {
        if (!_exists(_tokenId)) revert NonExistentToken();
        if (receivers.length != basisPoints.length) revert LengthMismatch();
        RoyaltyInfo[] storage tokenRoyalties = royaltyTokenInfo[_tokenId];
        if (tokenRoyalties.length != 0) revert TokenRoyaltiesAlreadySet();
        RoyaltyInfo[] memory royalties_ = royalties;
        uint256 baseLength = royalties.length;
        uint256 tokenLength = basisPoints.length;
        uint96[] memory totalBasisPoints = new uint96[](baseLength + basisPoints.length);
        for (uint256 i; i < baseLength; i++) {
            totalBasisPoints[i] = royalties_[i].basisPoints;
        }

        for (uint256 i; i < tokenLength; i++) {
            totalBasisPoints[i + baseLength] = basisPoints[i];
        }

        _checkRoyalties(totalBasisPoints);

        for (uint256 i; i < basisPoints.length; i++) {
            tokenRoyalties.push(RoyaltyInfo(receivers[i], basisPoints[i]));
        }
    }

    /**
     * @dev Sets the royalties for the contract
     * @param receivers "
     * @param basisPoints "
     */
    function _setBaseRoyalties(
        address payable[] memory receivers,
        uint96[] memory basisPoints
    ) internal {
        /// TODO: check for duplicates
        if (receivers.length != basisPoints.length) revert LengthMismatch();
        if (royalties.length != 0) revert RoyaltiesAlreadySet();
        _checkRoyalties(basisPoints);
        for (uint256 i; i < basisPoints.length; i++) {
            royalties.push(RoyaltyInfo(receivers[i], basisPoints[i]));
        }
        emit TokenRoyaltiesUpdated(receivers, basisPoints);
    }

    /**
     * @dev Removes default royalty information.
     */

    function _resetBaseRoyalty() internal virtual {
        if (royalties.length == 0) revert RoyaltiesNotSet();
        delete royalties;
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 _tokenId) internal virtual {
        RoyaltyInfo[] storage tokenRoyalties = royaltyTokenInfo[_tokenId];
        if (!_exists(_tokenId)) revert NonExistentToken();
        if (tokenRoyalties.length == 0) revert TokenRoyaltiesNotSet();
        delete royaltyTokenInfo[_tokenId];
    }

    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    function _exists(uint256) internal virtual returns (bool);

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool);

    /**
     * @dev Checks that the total basis points for the royalties do not exceed 10000 (100%)
     */
    function _checkRoyalties(uint96[] memory basisPoints) internal pure {
        uint256 totalBasisPoints;
        for (uint256 i; i < basisPoints.length; i++) {
            if (basisPoints[i] > 2500) revert OverMaxBasisPointAllowed();
            totalBasisPoints += basisPoints[i];
        }
        if (totalBasisPoints >= _feeDenominator()) revert InvalidRoyaltyConfig();
    }
}
