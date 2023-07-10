// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Deploy} from "script/Issuer.s.sol";

contract IssuerTest is Test, Deploy {
    function setUp() public virtual {
        Deploy.run();
    }
}

contract MintIssuer is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract Mint is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract MintWithTicket is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract UpdateIssuer is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract UpdatePrice is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract Burn is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract BurnSupply is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract SetCodex is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract GetIssuer is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract RoyaltyInfo is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract PrimarySplitInfo is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract SupportsInterfaces is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}
