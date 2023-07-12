// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Marketplace} from "contracts/marketplace/Marketplace.sol";

contract MarketPlaceTest is Test {
    address public admin = address(1);
    address public fxHashAdmin = address(2);
    address public addr1 = address(3);
    address public treasury = address(4);

    Marketplace public market;

    function setUp() public virtual {
        market = new Marketplace(admin, 100, 100, 10, treasury);
    }
}

contract SetAssetState is MarketPlaceTest {
    address public validAsset = address(420);
    address public invalidAsset = address(69);

    function test_setAssetState() public {
        vm.prank(admin);
        market.setAssetState(validAsset, true);

        assertTrue(market.assetContracts(validAsset));
    }

    function test_RevertsWhenNotAdmin() public {
        vm.expectRevert("Caller is not an admin");
        market.setAssetState(validAsset, true);

        assertFalse(market.assetContracts(validAsset));
    }

    function test_ReturnsInvalidAsset() public {
        assertFalse(market.assetContracts(invalidAsset));
    }
}

contract SetMaxReferralShare is MarketPlaceTest {}

contract SetReferralShare is MarketPlaceTest {}

contract SetPlatformFees is MarketPlaceTest {}

contract SetTreasury is MarketPlaceTest {}

contract AddCurrency is MarketPlaceTest {}

contract RemoveCurrency is MarketPlaceTest {}

contract List is MarketPlaceTest {}

contract CancelListing is MarketPlaceTest {}

contract BuyListing is MarketPlaceTest {}

contract Offer is MarketPlaceTest {}

contract CancelOffer is MarketPlaceTest {}

contract AcceptOffer is MarketPlaceTest {}
