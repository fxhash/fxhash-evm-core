// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/BaseTest.t.sol";
import "forge-std/Test.sol";
import {FixedPrice} from "src/minters/FixedPrice.sol";
import {ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {FxGenArt721, MintInfo, ProjectInfo} from "src/tokens/FxGenArt721.sol";

contract FirstComeFirstServeTest is BaseTest {
    FixedPrice internal sale;
    FxGenArt721 internal mockToken;
    uint256 internal price = 1 ether;
    uint256 internal quantity = 1;
    uint128 internal supply = 100;
    uint64 internal startTime = uint64(block.timestamp);
    uint64 internal endTime = type(uint64).max;

    function setUp() public override {
        super.setUp();
        mockToken = new FxGenArt721(address(fxContractRegistry), address(fxRoleRegistry));
        vm.deal(address(this), 100 ether);
        sale = new FixedPrice();
        vm.prank(admin);
        fxRoleRegistry.grantRole(MINTER_ROLE, address(sale));
        // fxContractRegistry.setContracts("MINTER", address(sale));
        projectInfo.supply = supply;
        mintInfo.push(
            MintInfo(address(sale), ReserveInfo(startTime, endTime, supply), abi.encode(price))
        );
        mockToken.initialize(
            address(this),
            address(this),
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            basisPoints
        );
        mockToken.toggleMint();
        vm.prank(admin);
        mockToken.setRandomizer(address(fxPsuedoRandomizer));
    }
}

contract BuyTokens is FirstComeFirstServeTest {
    function test_buyTokens() public {
        vm.warp(block.timestamp);
        sale.buyTokens{value: price}(address(mockToken), 0, 1, address(this));
        assertEq(mockToken.balanceOf(address(this)), 1);
    }

    function test_RevertsIf_BuyMoreThanAllocation() public {
        vm.expectRevert();
        sale.buyTokens{value: (price * (supply + 1))}(
            address(mockToken), 0, supply + 1, address(this)
        );
        assertEq(mockToken.balanceOf(address(this)), 0);
    }

    function test_RevertsIf_InsufficientPrice() public {
        vm.expectRevert();
        sale.buyTokens{value: price - 1}(address(mockToken), 0, 1, address(this));
        assertEq(mockToken.balanceOf(address(this)), 0);
    }

    function test_RevertsIf_NotStarted() public {
        vm.warp(block.timestamp - 1);
        vm.expectRevert();
        sale.buyTokens{value: price}(address(mockToken), 0, 1, address(this));
        assertEq(mockToken.balanceOf(address(this)), 0);
    }

    function test_RevertsIf_Ended() public {
        vm.warp(uint256(endTime) + 1);
        vm.expectRevert();
        sale.buyTokens{value: price}(address(mockToken), 0, 1, address(this));
        assertEq(mockToken.balanceOf(address(this)), 0);
    }

    function test_RevertsIf_TokenAddress0() public {
        vm.expectRevert();
        sale.buyTokens{value: price}(address(0), 0, 1, address(this));
        assertEq(mockToken.balanceOf(address(this)), 0);
    }

    function test_RevertsIf_ToAddress0() public {
        vm.expectRevert();
        sale.buyTokens{value: price}(address(mockToken), 0, 1, address(0));
    }

    function test_RevertsIf_Purchase0() public {
        vm.expectRevert();
        sale.buyTokens{value: price}(address(mockToken), 0, 0, address(this));
        assertEq(mockToken.balanceOf(address(this)), 0);
    }
}

contract SetMintDetails is FirstComeFirstServeTest {
    function test_setMintDetails() public {
        uint256 price = 10;
        uint128 allocation = 100;
        uint64 start = uint64(block.timestamp + 10);
        uint64 end = type(uint64).max;
        sale.setMintDetails(ReserveInfo(start, end, allocation), abi.encode(price));
        assertEq(sale.prices(address(this), 0), price, "price incorrectly set");
        (uint64 startTime, uint64 endTime, uint160 allocation_) = sale.reserves(address(this), 0);
        assertEq(sale.prices(address(this), 0), price, "price incorrectly set");
        assertEq(startTime, start, "startTime incorrectly set");
        assertEq(endTime, end, "endTime incorrectly set");
        assertEq(allocation_, allocation, "allocation incorrectly set");
    }

    function test_RevertsIf_StartTimeGtEndTime() public {
        endTime = startTime - 1;
        vm.expectRevert();
        sale.setMintDetails(ReserveInfo(startTime, endTime, supply), abi.encode(price));
    }

    function test_RevertsIf_Allocation0() public {
        vm.expectRevert();
        sale.setMintDetails(ReserveInfo(startTime, endTime, 0), abi.encode(price));
    }

    function test_RevertsIf_Price0() public {
        vm.expectRevert();
        sale.setMintDetails(ReserveInfo(startTime, endTime, supply), abi.encode(0));
    }
}

contract Withdraw is FirstComeFirstServeTest {
    receive() external payable {}

    function test_withdraw() public {
        sale.buyTokens{value: price}(address(mockToken), 0, 1, address(this));
        sale.withdraw(address(mockToken));
    }
}
