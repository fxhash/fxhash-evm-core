// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/**
 * @title MintFee
 * @author fx(hash)
 * @notice Extension for charging fees on token mints
 */
abstract contract MintFee {
    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Calculates the mint fee based on the amount of tokens being purchased
     */
    function _calculateFee(
        address _token,
        uint256 _price,
        uint256 _amount,
        uint256 _percentage
    ) internal returns (uint256 fee) {}
}
