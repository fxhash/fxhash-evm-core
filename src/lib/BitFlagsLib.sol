// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "src/utils/Constants.sol";

/// @title BitFlagsLib
/// @dev This library allows for comparing, editing, and reading bitflags easily
library BitFlagsLib {
    /// @dev Checks whether a combination of bitflags are valid
    function areFlagsValid(uint16 self) internal pure returns (bool) {
        if (isOpenEdition(self) && isSupplyCapped(self)) return false;
        if (isPublic(self)) {
            if (isAllowlisted(self) || isMintWithPass(self)) return false;
        }
        if (isMintWithPass(self) && isAllowlisted(self)) return false;
        return true;
    }

    /// @dev Checks whether the bitflag for a mint being an open edition is toggled
    /// @param self The bitflags to check
    /// @return True if the open edition bitflag is toggled, false otherwise
    function isOpenEdition(uint16 self) internal pure returns (bool) {
        return self & SUPPLY_CAPPED_FLAG == 0;
    }

    /// @dev Checks whether the bitflag for enforcing a supply cap is toggled
    /// @param self The bitflags to check
    /// @return True if the supply cap bitflag is toggled, false otherwise
    function isSupplyCapped(uint16 self) internal pure returns (bool) {
        return self & SUPPLY_CAPPED_FLAG != 0;
    }

    /// @dev Checks whether the bitflag for public mint is toggled
    /// @param self The bitflags to check
    /// @return True if the public bitflag is toggled, false otherwise
    function isPublic(uint16 self) internal pure returns (bool) {
        return self & PUBLIC_FLAG != 0;
    }

    /// @dev Checks whether the bitflag for mint from allowlist is toggled
    /// @param self The bitflags to check
    /// @return True if the allowlist bitflag is toggled, false otherwise
    function isAllowlisted(uint16 self) internal pure returns (bool) {
        return self & ALLOWLISTED_FLAG != 0;
    }

    /// @dev Checks whether the bitflag for mint with pass is toggled
    /// @param self The bitflags to check
    /// @return True if the Mint with pass bitflag is toggled, false otherwise
    function isMintWithPass(uint16 self) internal pure returns (bool) {
        return self & MINT_WITH_PASS_FLAG != 0;
    }

    /// @dev Checks whether the bitflag for mint tickets is toggled
    /// @param self The bitflags to check
    /// @return True if the mint ticket bitflag is toggled, false otherwise
    function isMintWithTicket(uint16 self) internal pure returns (bool) {
        return self & MINT_WITH_TICKET_FLAG != 0;
    }

    /// @dev Checks whether the bitflag for refundable is toggled
    /// @param self The bitflags to check
    /// @return True if the rebate bitflag is toggled, false otherwise
    function isRefundable(uint16 self) internal pure returns (bool) {
        return self & REBATE_FLAG != 0;
    }
}
