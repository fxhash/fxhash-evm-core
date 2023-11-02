// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "src/utils/Constants.sol";
import {Test} from "forge-std/Test.sol";
import {BitFlagsLib} from "src/lib/BitFlagsLib.sol";

contract BitFlagsLibTest is Test {
    using BitFlagsLib for uint16;

    function test_IsOpenEdition() public {
        assertTrue(BitFlagsLib.isOpenEdition(0));
    }

    function test_IsNotOpenEdition() public {
        assertFalse(BitFlagsLib.isOpenEdition(SUPPLY_CAPPED_FLAG));
    }

    function test_IsPublic() public {
        assertTrue(BitFlagsLib.isPublic(PUBLIC_FLAG));
    }

    function test_IsNotPublic() public {
        assertFalse(BitFlagsLib.isPublic(0));
    }

    function test_IsAllowlisted() public {
        assertTrue(BitFlagsLib.isAllowlisted(ALLOWLISTED_FLAG));
    }

    function test_IsNotAllowlisted() public {
        assertFalse(BitFlagsLib.isAllowlisted(0));
    }

    function test_IsMintWithPass() public {
        assertTrue(BitFlagsLib.isMintWithPass(MINT_WITH_PASS_FLAG));
    }

    function test_IsNotMintWithPass() public {
        assertFalse(BitFlagsLib.isMintWithPass(0));
    }

    function test_IsRefundable() public {
        assertTrue(BitFlagsLib.isRefundable(REBATE_FLAG));
    }

    function test_IsNotRefundable() public {
        assertFalse(BitFlagsLib.isRefundable(0));
    }
}
