// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ModerationTeam} from "contracts/moderation/ModerationTeam.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title BaseModeration
/// @notice Configures moderation settings
abstract contract BaseModeration is Ownable {
    /// @dev Counter for reason ID
    uint96 internal reasonsCount;
    /// @dev Address of Moderation contract
    address payable internal moderation;
    /// @notice Mapping of reason ID to reason
    mapping(uint256 => string) public reasons;

    /// @notice Thrown when caller is not the moderator
    error NotMod();
    /// @notice Thrown when reason value is empty
    error ReasonDoesNotExist();

    /// @dev Checks if caller is a moderator
    modifier onlyModerator() {
        if (!isModerator(msg.sender)) revert NotMod();
        _;
    }

    /// @dev Initializes Moderation contract
    constructor(address _moderation) {
        moderation = payable(_moderation);
    }

    /// @notice Adds new reason value
    /// @param _reason String value of reason
    function reasonAdd(string memory _reason) external onlyModerator {
        reasons[reasonsCount++] = _reason;
    }

    /// @notice Update existing reason value
    /// @param _reasonId ID of reason
    /// @param _reason Strinb value of reason
    function reasonUpdate(uint256 _reasonId, string memory _reason) external onlyModerator {
        if (bytes(reasons[_reasonId]).length == 0) revert ReasonDoesNotExist();
        reasons[_reasonId] = _reason;
    }

    /// @notice Sets new Moderation contract
    /// @param _moderation Address of Moderation contract
    function setModeration(address payable _moderation) external onlyOwner {
        moderation = _moderation;
    }

    /// @notice Checks if user is moderator
    /// @return moderation status of user
    function isModerator(address _user) public view virtual returns (bool);
}
