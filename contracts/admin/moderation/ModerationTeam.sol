// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AuthorizedCaller} from "contracts/admin/AuthorizedCaller.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IModerationTeam, TeamModInfo} from "contracts/interfaces/IModerationTeam.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

contract ModerationTeam is Ownable, IModerationTeam {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private modSet;
    uint256 public totalShares;
    mapping(address => TeamModInfo) public moderators;

    modifier onlyModerator() {
        if (!isModerator(msg.sender)) revert NotModerator();
        _;
    }

    modifier onlyModeratorOrAdmin() {
        if (!isModerator(msg.sender) || msg.sender == owner()) revert NotAuthorized();
        _;
    }

    constructor() {}

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function updateAuthorizations(
        address[] calldata _moderators,
        uint16[][] calldata _authorizations
    ) external onlyOwner {
        address moderator;
        uint16[] memory authorizations;
        uint256 length = _moderators.length;
        for (uint256 i; i < length; ) {
            moderator = _moderators[i];
            authorizations = _authorizations[i];
            if (authorizations.length == 0) {
                delete moderators[moderator];
                EnumerableSet.remove(modSet, moderator);
            } else {
                moderators[moderator].authorizations = authorizations;
                EnumerableSet.add(modSet, moderator);
            }

            unchecked {
                ++i;
            }
        }
        emit ModeratorsUpdated(_moderators, _authorizations);
    }

    function updateShares(
        address[] calldata _moderators,
        uint256[] calldata _shares
    ) external onlyOwner {
        address moderator;
        uint256 share;
        uint256 length = _moderators.length;
        for (uint256 i; i < length; ++i) {
            share = _shares[i];
            moderator = _moderators[i];

            if (share == 0) {
                delete moderators[moderator];
                if (totalShares > share) {
                    totalShares = totalShares - share;
                }
            } else {
                moderators[moderator].share = share;
                totalShares = totalShares + share;
            }
        }

        emit SharesUpdated(_moderators, _shares);
    }

    function withdraw() external onlyModeratorOrAdmin {
        if (totalShares > 0) {
            uint256 balance = address(this).balance;
            uint256 length = EnumerableSet.length(modSet);
            unchecked {
                for (uint256 i; i < length; ++i) {
                    address recipient = EnumerableSet.at(modSet, i);
                    uint256 amount = (balance * moderators[recipient].share) / totalShares;
                    SafeTransferLib.safeTransferETH(recipient, amount);
                }
            }
        }
    }

    function isAuthorized(address _account, uint16 _authorization) external view returns (bool) {
        uint16[] memory authorizations = moderators[_account].authorizations;
        uint256 length = authorizations.length;
        for (uint256 i; i < length; ) {
            if (authorizations[i] == _authorization) {
                return true;
            }
            unchecked {
                ++i;
            }
        }
    }

    function isModerator(address _account) public view returns (bool) {
        return moderators[_account].authorizations.length > 0;
    }
}
