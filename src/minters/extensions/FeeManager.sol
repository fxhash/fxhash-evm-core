// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Ownable} from "solady/src/auth/Ownable.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IFeeManager} from "src/interfaces/IFeeManager.sol";

contract FeeManager is IFeeManager, Ownable {
    uint128 public platformFee;
    uint64 public mintPercentage;
    uint64 public splitPercentage;

    mapping(address => uint128) public platformFees;
    mapping(address => uint64) public mintPercentages;
    mapping(address => uint64) public splitPercentages;

    constructor(address _owner, uint128 _platformFee, uint64 _mintPercentage, uint64 _splitPercentage) {
        _initializeOwner(_owner);
        platformFee = _platformFee;
        mintPercentage = _mintPercentage;
        splitPercentage = _splitPercentage;
    }

    receive() external payable {}

    function setPlatformFee(address _token, uint128 _platformFee) external onlyOwner {
        if (_token == address(0)) {
            emit PlatformFeeUpdated(_token, platformFee, _platformFee);
            platformFee = _platformFee;
        } else {
            emit PlatformFeeUpdated(_token, platformFees[_token], _platformFee);
            platformFees[_token] = _platformFee;
        }
    }

    function setMintPercentage(address _token, uint64 _mintPercentage) external onlyOwner {
        if (_token == address(0)) {
            emit MintPercentageUpdated(_token, mintPercentage, _mintPercentage);
            mintPercentage = _mintPercentage;
        } else {
            emit MintPercentageUpdated(_token, mintPercentages[_token], _mintPercentage);
            mintPercentages[_token] = _mintPercentage;
        }
    }

    function setSplitPercentage(address _token, uint64 _splitPercentage) external onlyOwner {
        if (_token == address(0)) {
            emit SplitPercentageUpdated(_token, splitPercentage, _splitPercentage);
            splitPercentage = _splitPercentage;
        } else {
            emit SplitPercentageUpdated(_token, splitPercentages[_token], _splitPercentage);
            splitPercentages[_token] = _splitPercentage;
        }
    }

    function withdraw(address _to) external onlyOwner {
        uint256 balance = address(this).balance;
        SafeTransferLib.safeTransferETH(_to, balance);
    }

    function calculateFee(
        address _token,
        uint256 _price,
        uint256 _amount
    ) external view returns (uint256 platform, uint256 mintFee, uint256 splitAmount) {
        platform = getPlatformFee(_token) * _amount;
        mintFee = (getMintPercentage(_token) * _price) / 10000;
        splitAmount = (getSplitPercentage(_token) * platform) / 10000;
    }

    function getPlatformFee(address _token) public view returns (uint128) {
        return platformFees[_token] == 0 ? platformFee : platformFees[_token];
    }

    function getMintPercentage(address _token) public view returns (uint64) {
        return mintPercentages[_token] == 0 ? mintPercentage : mintPercentages[_token];
    }

    function getSplitPercentage(address _token) public view returns (uint64) {
        return splitPercentages[_token] == 0 ? splitPercentage : splitPercentages[_token];
    }
}
