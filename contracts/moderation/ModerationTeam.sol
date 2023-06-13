// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "contracts/abstract/admin/FxHashAdmin.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ModerationTeam is FxHashAdmin {
    using EnumerableSet for EnumerableSet.AddressSet;
    event Received(address sender, uint256 amount);

    /*
    TYPES DEFINITION
    */
    struct ModeratorData {
        uint256[] authorizations;
        uint256 share;
    }

    struct UpdateModeratorParam {
        address moderator;
        uint256[] authorizations;
    }

    struct UpdateShareParam {
        address moderator;
        uint256 share;
    }

    /*
    STORAGE
    */
    uint256 sharesTotal;
    mapping(address => ModeratorData) public moderators;
    EnumerableSet.AddressSet private moderatorAddresses;

    /*
    MODIFIERS
    */

    modifier onlyModerator() {
        require(isModerator(msg.sender), "NOT_MODERATOR");
        _;
    }

    modifier onlyModeratorOrAdmin() {
        require(isModerator(msg.sender) || AccessControl.hasRole(
                FXHASH_ADMIN,
                _msgSender()
            ), "NOT_MODERATOR_OR_ADMIN");
        _;
    }

    /*
    INITIALIZATION
    */
    constructor(address _admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(FXHASH_ADMIN, _admin);
        sharesTotal = 0;
    }

    /*
    HELPERS
    */
    function isModerator(address _address) private view returns (bool) {
        return moderators[_address].authorizations.length > 0;
    }

    /*
    ENTRY POINTS
    */
    function updateModerators(
        UpdateModeratorParam[] calldata params
    ) external onlyAdmin {
        for (uint256 i = 0; i < params.length; i++) {
            UpdateModeratorParam memory mod = params[i];
            address userAddress = mod.moderator;
            uint256[] memory userAuthorizations = mod.authorizations;

            if (userAuthorizations.length == 0) {
                delete moderators[userAddress];
                EnumerableSet.remove(moderatorAddresses, userAddress);
            } else {
                moderators[userAddress].authorizations = userAuthorizations;
                EnumerableSet.add(moderatorAddresses, userAddress);
            }
        }
    }

    function updateShares(
        UpdateShareParam[] calldata params
    ) external onlyAdmin {
        for (uint256 i = 0; i < params.length; i++) {
            UpdateShareParam memory shareData = params[i];
            address shareAddress = shareData.moderator;
            uint256 sharePercentage = shareData.share;
            ModeratorData memory modData = moderators[shareAddress];

            if (sharePercentage == 0) {
                if (sharesTotal > modData.share) {
                    sharesTotal = sharesTotal - modData.share;
                }
                delete moderators[shareAddress];
            } else {
                moderators[shareAddress].share = sharePercentage;
                sharesTotal = sharesTotal + sharePercentage;
            }
        }
    }

    function withdraw() external onlyModeratorOrAdmin {
        uint256 amount = address(this).balance;
        if(sharesTotal > 0) {
            for (uint256 i = 0; i < EnumerableSet.length(moderatorAddresses); i++) {
                address recipient = EnumerableSet.at(moderatorAddresses, i);
                uint256 share = moderators[recipient].share;
                payable(recipient).transfer(SafeMath.div(SafeMath.mul(amount, share), sharesTotal));
            }
        }
        
    }

    /*
    VIEWS
    */
    function getAuthorizations(
        address userAddress
    ) external view returns (uint256[] memory) {
        return moderators[userAddress].authorizations;
    }

    function isAuthorized(
        address userAddress,
        uint256 authorization
    ) external view returns (bool) {
        bool isModAuthorized = false;
        uint256[] memory modAuth = moderators[userAddress].authorizations;
        for (uint256 i = 0; i < modAuth.length; i++) {
            if (modAuth[i] == authorization) {
                isModAuthorized = true;
            }
        }
        return isModAuthorized;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
