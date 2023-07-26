// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {MockRoyaltyManager} from "test/foundry/mocks/MockRoyaltyManager.sol";

contract RoyaltyManagerTest is Test {
    MockRoyaltyManager public royaltyManager;

    function setUp() public {
        royaltyManager = new MockRoyaltyManager();
    }
}

contract SetBaseRoyalties is RoyaltyManagerTest {
    function test_SetBaseRoyalties() public {
        this;
    }

    function test_RevertsWhen_SingleGt25() public {
        this;
    }

    function test_RevertsWhen_AllGt100() public {
        this;
    }

    function test_RevertsWhen_Duplicate() public {
        this;
    }

    function test_RevertsWhen_LenthMismatch() public {
        this;
    }

    function test_RevertsWhen_RoyaltiesAlreadySet() public {
        this;
    }
}

contract SetTokenRoyalties is RoyaltyManagerTest {
    function test_SetTokenRoyalties() public {
        this;
    }

    function test_RevertsWHen_TokenDoesntExist() public {
        this;
    }

    function test_RevertsWhen_SingleGt25() public {
        this;
    }

    function test_RevertsWhen_TokenAndBaseGt100() public {
        this;
    }

    function test_RevertsWhen_Duplicate() public {
        this;
    }

    function test_RevertsWhen_LenthMismatch() public {
        this;
    }

    function test_RevertsWhen_RoyaltiesAlreadySet() public {
        this;
    }
}

contract ResetDefaultRoyalties is RoyaltyManagerTest {
    function test_ResetBaseRoyalty() public {
        this;
    }
}

contract ResetTokenRoyalties is RoyaltyManagerTest {
    function test_ResetTokenRoyalty() public {
        this;
    }

    function test_RevertsWhen_TokenDoesntExist() public {
        this;
    }
}
