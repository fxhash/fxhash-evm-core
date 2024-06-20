// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Ownable} from "solady/src/auth/Ownable.sol";

/**
 * @title MintFee
 * @author fx(hash)
 * @notice Extension for charging fees on token mints
 */
abstract contract MintFee {
    /*//////////////////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    uint256 public mintFee;

    /*//////////////////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor() {
        // _initializeOwner(_owner);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Sets the new mint fee amount
     */
    function setMintFee(uint256 _fee) external virtual {}

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
