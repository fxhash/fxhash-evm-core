// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Deploy} from "script/DeployScript.s.sol";
import {ProjectFactory, IProjectFactory} from "contracts/factories/ProjectFactory.sol";
import {GenTkFactory, IGenTkFactory} from "contracts/factories/GenTkFactory.sol";
import {IssuerFactory, IIssuerFactory} from "contracts/factories/IssuerFactory.sol";

contract ProjectFactoryTest is Test, Deploy {
    event NewIssuerCreated(address indexed _owner, address _configManager, address indexed issuer);
    event NewGenTkCreated(
        address indexed _owner,
        address indexed _issuer,
        address _configManager,
        address indexed genTk
    );
    event NewProjectCreated(
        address indexed _owner,
        address indexed _issuer,
        address indexed genTk,
        address _configManager
    );
}

contract CreateProject is ProjectFactoryTest {
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
        emit NewIssuerCreated(alice, address(configurationManager), address(0));
        vm.expectEmit(true, false, false, false, address(genTkFactory));
        emit NewGenTkCreated(alice, address(0), address(configurationManager), address(0));
        vm.expectEmit(true, false, false, false, address(projectFactory));
        emit NewProjectCreated(alice, address(0), address(0), address(configurationManager));
        (address issuer, address gentk) = projectFactory.createProject(
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
