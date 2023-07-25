// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IRoyaltyManager} from "contracts/interfaces/IRoyaltyManager.sol";

abstract contract RoyaltyManager is IRoyaltyManager {
    bool public perTokenRoyaltiesEnabled;
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

    /// @notice Royalty configuration is greater than or equal to 100% in terms of basisPoints
    error InvalidRoyaltyConfig();

    /// @notice Reverts if the token Id hasn't been minted
    error NonExistentToken();

    /**
     * @dev Sets the royalties for the contract
     */
    function setRoyalties(
        address payable[] memory receivers,
        uint96[] memory basisPoints
    ) external virtual {
        _setRoyalties(receivers, basisPoints);
    }

    function _setTokenRoyalties(
        address payable[] memory receivers,
        uint96[] memory basisPoints
    ) internal virtual {
        _setRoyalties(receivers, basisPoints);
    }

    /**
     * @dev Sets the royalties for the contract
     * @param receivers "
     * @param basisPoints "
     */
    function _setRoyalties(
        address payable[] memory receivers,
        uint96[] memory basisPoints
    ) internal {
        _checkRoyalties(receivers, basisPoints);
        require(receivers.length == basisPoints.length, "Length Mismatch");
        for (uint256 i; i < basisPoints.length; i++) {
            royalties.push(RoyaltyInfo(receivers[i], basisPoints[i]));
        }
        emit TokenRoyaltiesUpdated(receivers, basisPoints);
    }

    /**
     * @dev Returns the royalty amount
     */

    function _getRoyalties(
        uint256 _tokenId,
        uint96 _value
    ) internal view returns (address payable[] memory receivers, uint96[] memory royaltyPayments) {
        RoyaltyInfo[] memory royalties_ = royalties;
        RoyaltyInfo[] storage tokenRoyalties = royaltyTokenInfo[_tokenId];
        uint256 baseLength = royalties.length;
        uint256 tokenLength = tokenRoyalties.length;
        receivers = new address payable[](baseLength + tokenLength);
        royaltyPayments = new uint96[](baseLength + tokenLength);
        for (uint256 i; i < baseLength; i++) {
            (receivers[i], royaltyPayments[i]) = (
                royalties_[i].receiver,
                (royalties_[i].basisPoints * _value) / 10_000
            );
        }

        for (uint256 i; i < tokenLength; i++) {
            (receivers[i + baseLength], royaltyPayments[i + baseLength]) = (
                tokenRoyalties[i].receiver,
                (tokenRoyalties[i].basisPoints * _value) / 10_000
            );
        }
    }

    /**
     * @dev Checks that the total basis points for the royalties do not exceed 10000 (100%)
     */
    function _checkRoyalties(
        address payable[] memory receivers,
        uint96[] memory basisPoints
    ) internal pure {
        uint256 totalBasisPoints;
        require(receivers.length == basisPoints.length, "Length Mismatch");
        for (uint256 i; i < basisPoints.length; i++) {
            totalBasisPoints += basisPoints[i];
        }
        if (totalBasisPoints >= 10_000) revert InvalidRoyaltyConfig();
    }
}
