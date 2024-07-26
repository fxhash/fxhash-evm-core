// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Ownable} from "solady/src/auth/Ownable.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IFeeManager, CustomFee} from "src/interfaces/IFeeManager.sol";
import {SCALE_FACTOR} from "src/utils/Constants.sol";

contract FeeManager is IFeeManager, Ownable {
    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFeeManager
     */
    uint120 public platformFee;

    /**
     * @inheritdoc IFeeManager
     */
    uint64 public mintPercentage;

    /**
     * @inheritdoc IFeeManager
     */
    uint64 public splitPercentage;

    /**
     * @inheritdoc IFeeManager
     */
    mapping(address => CustomFee) public customFees;

    /*//////////////////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Initializes contract owner and default platform fee, mint percentage and split percentage values
     */
    constructor(address _owner, uint120 _platformFee, uint64 _mintPercentage, uint64 _splitPercentage) {
        _initializeOwner(_owner);
        _setDefaultFees(_platformFee, _mintPercentage, _splitPercentage);
    }

    /**
     * @dev Fallback for receiving ether
     */
    receive() external payable {}

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFeeManager
     */
    function calculateFees(
        address _token,
        uint256 _price,
        uint256 _amount
    ) external view returns (uint256 platformAmount, uint256 mintAmount, uint256 splitAmount) {
        (uint120 platform, uint64 mint, uint64 split) = getFeeValues(_token);
        platformAmount = platform * _amount;
        mintAmount = (mint * _price) / SCALE_FACTOR;
        splitAmount = (split * platformAmount) / SCALE_FACTOR;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFeeManager
     */
    function getFeeValues(address _token) public view returns (uint120, uint64, uint64) {
        CustomFee memory customFee = customFees[_token];
        if (customFee.enabled) {
            return (customFee.platformFee, customFee.mintPercentage, customFee.splitPercentage);
        } else {
            return (platformFee, mintPercentage, splitPercentage);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFeeManager
     */
    function setCustomFees(
        address _token,
        bool _enabled,
        uint120 _platformFee,
        uint64 _mintPercentage,
        uint64 _splitPercentage
    ) external onlyOwner {
        if (_mintPercentage > SCALE_FACTOR || _splitPercentage > SCALE_FACTOR) revert InvalidPercentage();
        customFees[_token] = CustomFee({
            enabled: _enabled,
            platformFee: _platformFee,
            mintPercentage: _mintPercentage,
            splitPercentage: _splitPercentage
        });

        emit CustomFeesUpdated(_token, _enabled, _platformFee, _mintPercentage, _splitPercentage);
    }

    /**
     * @inheritdoc IFeeManager
     */
    function setDefaultFees(uint120 _platformFee, uint64 _mintPercentage, uint64 _splitPercentage) external onlyOwner {
        _setDefaultFees(_platformFee, _mintPercentage, _splitPercentage);
    }

    /**
     * @inheritdoc IFeeManager
     */
    function withdraw(address _to) external onlyOwner {
        uint256 balance = address(this).balance;
        SafeTransferLib.safeTransferETH(_to, balance);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Sets the default fee values used for all tokens where no custom fees are enabled
     */
    function _setDefaultFees(uint120 _platformFee, uint64 _mintPercentage, uint64 _splitPercentage) internal {
        if (_mintPercentage > SCALE_FACTOR || _splitPercentage > SCALE_FACTOR) revert InvalidPercentage();
        platformFee = _platformFee;
        mintPercentage = _mintPercentage;
        splitPercentage = _splitPercentage;

        emit DefaultFeesUpdated(_platformFee, _mintPercentage, _splitPercentage);
    }
}
