// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {CustomFee} from "src/lib/Structs.sol";

/**
 * @title IFeeManager
 * @author fx(hash)
 * @notice Minter extension for managing fees from primary token sales
 */
interface IFeeManager {
    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when custom fees for a token are updated
     * @param _token Address of token contract
     * @param _enabled Flag indicating if token has custom fees enabled
     * @param _platformFee Flat fee amount collected from token mints
     * @param _mintPercentage Percentage value of token price from primary sales
     * @param _splitPercentage Percentage value of platform fees split with creator
     */
    event CustomFeesUpdated(
        address _token,
        bool _enabled,
        uint120 _platformFee,
        uint64 _mintPercentage,
        uint64 _splitPercentage
    );

    /**
     * @notice Event emitted when default fees are updated
     * @param _platformFee Flat fee amount collected from token mints
     * @param _mintPercentage Percentage value of token price from primary sales
     * @param _splitPercentage Percentage value of platform fees split with creator
     */
    event DefaultFeesUpdated(uint120 _platformFee, uint64 _mintPercentage, uint64 _splitPercentage);

    /*//////////////////////////////////////////////////////////////////////////
                                  ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Error thrown when mint or split percentage values are greater than scaling factor value
     */
    error InvalidPercentage();

    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Caculates the platform, mint and split values for token mints
     * @param _token Address of the token contract
     * @param _price Total price of the mint
     * @param _amount Number of tokens being purchased
     * @return platformAmount, mintAmount, and splitAmount
     */
    function calculateFees(
        address _token,
        uint256 _price,
        uint256 _amount
    ) external view returns (uint256, uint256, uint256);

    /**
     * @notice Mapping of token address to struct of custom fees
     * @return enabled, platformFee, mintPercentage, and splitPercentage
     */
    function customFees(address _token) external view returns (bool, uint120, uint64, uint64);

    /**
     * @notice Gets default or custom fee values based on whether token has custom fees enabled
     * @return platformFee, mintPercentage, and splitPercentage
     */
    function getFees(address _token) external view returns (uint120, uint64, uint64);

    /**
     * @notice Returns the default mint percentage value of token price from the primary sales
     */
    function mintPercentage() external view returns (uint64);

    /**
     * @notice Returns the default platform fee collected from token mints
     */
    function platformFee() external view returns (uint120);

    /**
     * @notice Sets the custom fees for a token
     * @param _token Address of token contract
     * @param _enabled Flag indicating if token has custom fees enabled
     * @param _platformFee Flat fee amount collected from token mints
     * @param _mintPercentage Percentage value of token price from primary sales
     * @param _splitPercentage Percentage value of platform fees split with creator
     */
    function setCustomFees(
        address _token,
        bool _enabled,
        uint120 _platformFee,
        uint64 _mintPercentage,
        uint64 _splitPercentage
    ) external;

    /**
     * @notice Sets the default fees for all tokens
     * @param _platformFee Flat fee amount collected from token mints
     * @param _mintPercentage Percentage value of token price from primary sales
     * @param _splitPercentage Percentage value of platform fees split with creator
     */
    function setDefaultFees(uint120 _platformFee, uint64 _mintPercentage, uint64 _splitPercentage) external;

    /**
     * @notice Returns the default split percentage
     */
    function splitPercentage() external view returns (uint64);

    /**
     * @notice Withdraws total balance from contract
     * @param _to Address receiving funds
     */
    function withdraw(address _to) external;
}
