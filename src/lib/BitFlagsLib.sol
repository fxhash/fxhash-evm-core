// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "src/utils/Constants.sol";

/// @title BitFlagsLib
/// @dev This library allows for comparing, editing, and reading bitflags easily
library BitFlagsLib {
    function isOpenEdition(uint16 self) internal pure returns (bool) {
        return self & SUPPLY_CAPPED_FLAG == 0;
    }

    function isSupplyCapped(uint16 self) internal pure returns (bool) {
        return self & SUPPLY_CAPPED_FLAG != 0;
    }

    function isPublic(uint16 self) internal pure returns (bool) {
        return self & PUBLIC_FLAG != 0;
    }

    function isAllowlisted(uint16 self) internal pure returns (bool) {
        return self & ALLOWLISTED_FLAG != 0;
    }

    function isMintWithPass(uint16 self) internal pure returns (bool) {
        return self & MINT_WITH_PASS_FLAG != 0;
    }

    function isMintWithTicket(uint16 self) internal pure returns (bool) {
        return self & MINT_WITH_TICKET_FLAG != 0;
    }

    function isRefundable(uint16 self) internal pure returns (bool) {
        return self & REBATE_FLAG != 0;
    }
}
