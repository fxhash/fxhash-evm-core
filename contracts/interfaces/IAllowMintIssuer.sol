// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ModerationUser} from "contracts/moderation/ModerationUser.sol";

interface IAllowMintIssuer {
    error AccountBanned();

    function isAllowed(address _account) external view returns (bool);

    function mintDelay() external view returns (uint96);

    function updateMintDelay(uint96 _delay) external;

    function updateUserModerationContract(address _contract) external;

    function userModerationContract() external view returns (ModerationUser);
}
