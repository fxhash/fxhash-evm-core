// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/factories/FxIssuerFactory/FxIssuerFactoryTest.t.sol";

contract CreateProject is FxIssuerFactoryTest {
    address internal deterministicToken;
    bytes internal projectCreationInfo;
    bytes internal ticketCreationInfo;

    function setUp() public virtual override {
        super.setUp();
        ticketId = 1;
        deterministicToken = fxIssuerFactory.getTokenAddress(deployer);
    }

    function test_CreateProject() public {
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator,
            initInfo,
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            allocations,
            basisPoints
        );
        assertEq(fxIssuerFactory.projects(projectId), fxGenArtProxy);
        assertEq(FxGenArt721(fxGenArtProxy).owner(), creator);
    }

    function test_CreateProject_WithSingleParameter() public {
        projectCreationInfo = abi.encode(
            creator,
            initInfo,
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            allocations,
            basisPoints
        );
        fxGenArtProxy = fxIssuerFactory.createProject(projectCreationInfo);
        assertEq(fxIssuerFactory.projects(projectId), fxGenArtProxy);
        assertEq(FxGenArt721(fxGenArtProxy).owner(), creator);
    }

    function test_CreateProject_WithTicket() public {
        projectCreationInfo = abi.encode(
            creator,
            initInfo,
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            allocations,
            basisPoints
        );
        ticketCreationInfo = abi.encode(
            creator,
            deterministicToken,
            address(ticketRedeemer),
            address(ipfsRenderer),
            uint48(ONE_DAY),
            mintInfo
        );
        (fxGenArtProxy, fxMintTicketProxy) = fxIssuerFactory.createProject(
            projectCreationInfo,
            ticketCreationInfo,
            address(fxTicketFactory)
        );
        assertEq(fxIssuerFactory.projects(projectId), fxGenArtProxy);
        assertEq(FxGenArt721(fxGenArtProxy).owner(), creator);
        assertEq(fxTicketFactory.tickets(ticketId), fxMintTicketProxy);
        assertEq(FxMintTicket721(fxMintTicketProxy).owner(), creator);
    }

    function test_RevertsWhen_InvalidOwner() public {
        vm.expectRevert(INVALID_OWNER_ERROR);
        fxGenArtProxy = fxIssuerFactory.createProject(
            address(0),
            initInfo,
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            allocations,
            basisPoints
        );
    }
}
