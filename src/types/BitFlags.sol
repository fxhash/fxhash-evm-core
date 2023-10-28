// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

type BitFlags is uint16;

using {add as +, equals as ==} for BitFlags global;

function equals(BitFlags bitFlags, BitFlags other) pure returns (bool) {
    return BitFlags.unwrap(bitFlags) == BitFlags.unwrap(other);
}

function add(BitFlags bitFlags, BitFlags other) pure returns (BitFlags) {
    return BitFlags.wrap(BitFlags.unwrap(bitFlags) | BitFlags.unwrap(other));
}

/// @title BitFlagsLibrary
/// @dev This library allows for comparing, editing, and reading bitflags easily
library BitFlagsLibrary {
    using BitFlagsLibrary for BitFlags;
    using BitFlagsLibrary for uint16;
    /// supply related
    uint16 internal constant OPEN_EDITION_FLAG = 1 << 0;
    uint16 internal constant SUPPLY_CAPPED_FLAG = 1 << 1;
    /// presale validation
    uint16 internal constant ALLOWLISTED_FLAG = 1 << 4;
    uint16 internal constant MINT_WITH_PASS_FLAG = 1 << 5;
    uint16 internal constant MINT_WITH_TICKET_FLAG = 1 << 6;
    /// post sale considerations
    uint16 internal constant REFUNDABLE_FLAG = 1 << 8;

    function isOpenEdition(BitFlags self) internal pure returns (bool) {
        return self.fromBitFlags() & OPEN_EDITION_FLAG != 0;
    }

    function isSupplyCapped(BitFlags self) internal pure returns (bool) {
        return self.fromBitFlags() & SUPPLY_CAPPED_FLAG != 0;
    }

    function isAllowlisted(BitFlags self) internal pure returns (bool) {
        return self.fromBitFlags() & ALLOWLISTED_FLAG != 0;
    }

    function isMintWithPass(BitFlags self) internal pure returns (bool) {
        return self.fromBitFlags() & MINT_WITH_PASS_FLAG != 0;
    }

    function isMintWithTicket(BitFlags self) internal pure returns (bool) {
        return self.fromBitFlags() & MINT_WITH_TICKET_FLAG != 0;
    }

    function isRefundable(BitFlags self) internal pure returns (bool) {
        return self.fromBitFlags() & REFUNDABLE_FLAG != 0;
    }

    function validateBitFlags(BitFlags self) internal pure returns (bool) {
        if (self == OPEN_EDITION_FLAG.toBitFlags()) return true;
        if (self == SUPPLY_CAPPED_FLAG.toBitFlags()) return true;
        if (self == (SUPPLY_CAPPED_FLAG.toBitFlags() + ALLOWLISTED_FLAG.toBitFlags())) return true;
        if (self == (OPEN_EDITION_FLAG.toBitFlags() + ALLOWLISTED_FLAG.toBitFlags())) return true;
        if (self == (SUPPLY_CAPPED_FLAG.toBitFlags() + MINT_WITH_PASS_FLAG.toBitFlags())) return true;
        if (self == (OPEN_EDITION_FLAG.toBitFlags() + MINT_WITH_PASS_FLAG.toBitFlags())) return true;
        if (self == (SUPPLY_CAPPED_FLAG.toBitFlags() + MINT_WITH_TICKET_FLAG.toBitFlags())) return true;
        return false;
    }

    function fromBitFlags(BitFlags self) internal pure returns (uint16) {
        return BitFlags.unwrap(self);
    }

    function toBitFlags(uint16 self) internal pure returns (BitFlags) {
        return BitFlags.wrap(self);
    }
}
