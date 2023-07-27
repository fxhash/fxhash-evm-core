// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

struct TeamModInfo {
    uint256 share;
    uint16[] authorizations;
}

interface IModerationTeam {
    error NotAuthorized();
    error NotModerator();

    event ModeratorsUpdated(address[] _moderators, uint16[][] authorizations);
    event Received(address _sender, uint256 _amount);
    event SharesUpdated(address[] _moderators, uint256[] _shares);

    /// @notice Checks if moderator is authorized to perform action
    /// @param _account Address of the moderator
    /// @param _authorization ID of the authorization code
    /// @return status of the authorization
    function isAuthorized(address _account, uint16 _authorization) external view returns (bool);
}
