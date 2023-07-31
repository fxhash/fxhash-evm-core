// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Cycles, ICycles, CycleParams} from "contracts/admin/config/Cycles.sol";

contract CyclesTest is Test {
    address public admin = address(1);
    address public fxHashAdmin = address(2);
    address public addr1 = address(3);
    bytes32 public AUTHORIZED_CALLER = keccak256("AUTHORIZED_CALLER");
    CycleParams public params;
    Cycles public cycles;

    function setUp() public virtual {
        cycles = new Cycles();
        cycles.grantAuthorizedCallerRole(fxHashAdmin);
    }
}

contract AddCycle is CyclesTest {
    function setUp() public virtual override {
        super.setUp();
        params = CycleParams(100, 50, 100);
    }

    function test_addCycle() public {
        cycles.addCycle(params);
        (uint256 start, uint256 openDuration, uint256 closeDuration) = cycles.cycles(0);
        assertEq(start, params.start);
        assertEq(openDuration, params.openingDuration);
        assertEq(closeDuration, params.closingDuration);
    }
}

contract RemoveCycle is CyclesTest {
    function setUp() public virtual override {
        super.setUp();
        params = CycleParams(100, 50, 100);
        cycles.addCycle(params);
    }

    function test_removeCycle() public {
        cycles.removeCycle(0);
    }
}

contract AreCyclesOpen is CyclesTest {
    function setUp() public virtual override {
        super.setUp();
        params = CycleParams(100, 50, 100);
        cycles.addCycle(params);
    }

    // function test_areCyclesOpen() public {}
}
