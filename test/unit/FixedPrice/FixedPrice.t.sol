// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/BaseTest.t.sol";
import "forge-std/Test.sol";
import {IFixedPrice} from "src/interfaces/IFixedPrice.sol";
import {FixedPrice} from "src/minters/FixedPrice.sol";
import {ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {FxGenArt721, MintInfo, ProjectInfo} from "src/tokens/FxGenArt721.sol";

contract FixedPriceTest is BaseTest {
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
        vm.deal(address(this), 1000 ether);
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
        mockToken.setRandomizer(address(fxPseudoRandomizer));
    }
}
