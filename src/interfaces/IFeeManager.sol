// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {CustomFee} from "src/lib/Structs.sol";

interface IFeeManager {
    event CustomFeesUpdated(
        address _token,
        bool _enabled,
        uint120 _platformFee,
        uint64 _mintPercentage,
        uint64 _splitPercentage
    );

    event DefaultFeesUpdated(uint120 _platformFee, uint64 _mintPercentage, uint64 _splitPercentage);

    error InvalidPercentage();

    function setCustomFees(
        address token,
        bool _enabled,
        uint120 _platformFee,
        uint64 _mintPercentage,
        uint64 _splitPercentage
    ) external;

    function setDefaultFees(uint120 _platformFee, uint64 _mintPercentage, uint64 _splitPercentage) external;

    function withdraw(address _to) external;

    function calculateFees(
        address _token,
        uint256 _price,
        uint256 _amount
    ) external view returns (uint256, uint256, uint256);

    function customFees(address _token) external view returns (bool, uint120, uint64, uint64);

    function getFees(address _token) external view returns (uint120, uint64, uint64);

    function mintPercentage() external view returns (uint64);

    function platformFee() external view returns (uint120);

    function splitPercentage() external view returns (uint64);
}
