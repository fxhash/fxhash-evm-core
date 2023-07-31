// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Deploy} from "script/Deploy.s.sol";
import {FxHashFactory, IFxHashFactory} from "contracts/factories/FxHashFactory.sol";
import {GenTkFactory, IGenTkFactory} from "contracts/factories/GenTkFactory.sol";
import {IssuerFactory, IIssuerFactory} from "contracts/factories/IssuerFactory.sol";

contract FxHashFactoryTest is Test, Deploy {
    event IssuerCreated(address indexed _owner, address _configManager, address indexed issuer);
    event GenTkCreated(
        address indexed _owner,
        address indexed _issuer,
        address _configManager,
        address indexed genTk
    );
    event FxHashProjectCreated(
        address indexed _owner,
        address indexed _issuer,
        address indexed genTk,
        address _configManager
    );
}

contract CreateProject is FxHashFactoryTest {
    address payable[] public royaltyReceivers;
    uint96[] public royaltyBasisPoints;

    function setUp() public virtual override {
        createAccounts();
        royaltyReceivers.push(payable(alice));
        royaltyBasisPoints.push(1500);
        Deploy.run();
    }

    function test_createProject() public {
        vm.expectEmit(true, false, false, false, address(issuerFactory));
        emit IssuerCreated(alice, address(configurationManager), address(0));
        vm.expectEmit(true, false, false, false, address(genTkFactory));
        emit GenTkCreated(alice, address(0), address(configurationManager), address(0));
        vm.expectEmit(true, false, false, false, address(fxHashFactory));
        emit FxHashProjectCreated(alice, address(0), address(0), address(configurationManager));
        (address issuer, address gentk) = fxHashFactory.createProject(
            royaltyReceivers,
            royaltyBasisPoints,
            alice
        );
        assertNotEq(issuer, address(0));
        assertNotEq(gentk, address(0));
        assertEq(issuer.code.length > 0, true);
        assertEq(gentk.code.length > 0, true);
    }
}
