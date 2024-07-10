// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface IFeeManager {
    event CustomFeesUpdated(address _token, bool _prevFlag, bool _newFlag);

    event PlatformFeeUpdated(address _token, uint128 _prevFee, uint128 _newFee);

    event MintPercentageUpdated(address _token, uint64 _prevPercentage, uint64 _newPercentage);

    event SplitPercentageUpdated(address _token, uint64 _prevPercentage, uint64 _newPercentage);

    error InvalidPercentage();

    function setCustomFees(address token, bool _flag) external;

    function setPlatformFee(address token, uint128 _platformFee) external;

    function setMintPercentage(address token, uint64 _mintPercentage) external;

    function setSplitPercentage(address token, uint64 _splitPercentage) external;

    function withdraw(address _to) external;

    function calculateFee(
        address _token,
        uint256 _price,
        uint256 _amount
    ) external view returns (uint256, uint256, uint256);

    function customFees(address _token) external view returns (bool);

    function mintPercentage() external view returns (uint64);

    function mintPercentages(address _token) external view returns (uint64);

    function platformFee() external view returns (uint128);

    function platformFees(address _token) external view returns (uint128);

    function splitPercentage() external view returns (uint64);

    function splitPercentages(address _token) external view returns (uint64);
}
