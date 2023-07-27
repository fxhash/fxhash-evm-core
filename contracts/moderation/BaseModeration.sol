// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title BaseModeration
/// @notice Configures user moderation settings
abstract contract BaseModeration is Ownable {
    /// @notice Malicious state of moderation
    uint16 public constant MALICIOUS = 3;
    /// @notice Verified state of moderation
    uint16 public constant VERIFIED = 10;
    /// @notice Address of Moderation contract
    address payable public moderation;
    /// @notice Counter for reason ID
    uint96 public reasonId;
    /// @notice Mapping of reason ID to reason
    mapping(uint128 => string) public reasons;

    /// @notice Thrown when caller is not a moderator
    error NotModerator();
    /// @notice Thrown when reason value is empty
    error ReasonDoesNotExist();

    /// @dev Checks if caller is a moderator
    modifier onlyModerator() {
        if (!isModerator(msg.sender)) revert NotModerator();
        _;
    }

    /// @dev Initializes Moderation contract
    constructor(address payable _moderation) {
        moderation = _moderation;
    }

    /// @notice Sets new Moderation contract
    /// @param _moderation Address of Moderation contract
    function setModeration(address payable _moderation) external onlyOwner {
        moderation = _moderation;
    }

    /// @notice Adds new reason value
    /// @param _reason String value of reason
    function addReason(string calldata _reason) external onlyModerator {
        reasons[reasonId++] = _reason;
    }

    /// @notice Update existing reason value
    /// @param _reasonId ID of reason
    /// @param _reason String value of reason
    function updateReason(uint128 _reasonId, string calldata _reason) external onlyModerator {
        if (bytes(reasons[_reasonId]).length == 0) revert ReasonDoesNotExist();
        reasons[_reasonId] = _reason;
    }

    /// @notice Checks if account is a moderator
    /// @return moderation status of account
    function isModerator(address _account) public view virtual returns (bool);
}
