// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "src/utils/Constants.sol";
import {Test} from "forge-std/Test.sol";
import {BitFlags, BitFlagsLibrary} from "src/types/BitFlags.sol";

contract BitFlagsTest is Test {
    using BitFlagsLibrary for BitFlags;

    function test_Equals() public {
        BitFlags first = BitFlagsLibrary.toBitFlags(0);
        BitFlags other = BitFlagsLibrary.toBitFlags(0);
        assertTrue(first == other);
    }

    function test_Add() public {
        BitFlags first = BitFlagsLibrary.toBitFlags(2);
        BitFlags other = BitFlagsLibrary.toBitFlags(1);
        assertEq(BitFlags.unwrap(first + other), 3);
    }

    function test_IsOpenEdition() public {
        assertTrue(BitFlagsLibrary.isOpenEdition(BitFlags.wrap(0)));
    }

    function test_IsNotOpenEdition() public {
        assertFalse(BitFlagsLibrary.isOpenEdition(BitFlags.wrap(SUPPLY_CAPPED_FLAG)));
    }

    function test_IsPublic() public {
        assertTrue(BitFlagsLibrary.isPublic(BitFlags.wrap(PUBLIC_FLAG)));
    }

    function test_IsNotPublic() public {
        assertFalse(BitFlagsLibrary.isPublic(BitFlags.wrap(0)));
    }

    function test_IsAllowlisted() public {
        assertTrue(BitFlagsLibrary.isAllowlisted(BitFlags.wrap(ALLOWLISTED_FLAG)));
    }

    function test_IsNotAllowlisted() public {
        assertFalse(BitFlagsLibrary.isAllowlisted(BitFlags.wrap(0)));
    }

    function test_IsMintWithPass() public {
        assertTrue(BitFlagsLibrary.isMintWithPass(BitFlags.wrap(MINT_WITH_PASS_FLAG)));
    }

    function test_IsNotMintWithPass() public {
        assertFalse(BitFlagsLibrary.isMintWithPass(BitFlags.wrap(0)));
    }

    function test_IsRefundable() public {
        assertTrue(BitFlagsLibrary.isRefundable(BitFlags.wrap(REBATE_FLAG)));
    }

    function test_IsNotRefundable() public {
        assertFalse(BitFlagsLibrary.isRefundable(BitFlags.wrap(0)));
    }
}
