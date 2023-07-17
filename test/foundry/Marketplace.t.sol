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
        vm.expectRevert(
            "AccessControl: account 0x7fa9385be102ac3eac297483dd6233d62b3e1496 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000"
        );
        market.setAssetState(validAsset, true);

        assertFalse(market.assetContracts(validAsset));
    }

    function test_ReturnsInvalidAsset() public {
        assertFalse(market.assetContracts(invalidAsset));
    }
}

contract SetMaxReferralShare is MarketPlaceTest {
    uint256 public maxReferralShare = 1000;

    function test_setMaxReferralShare() public {
        vm.prank(admin);
        market.setMaxReferralShare(maxReferralShare);

        assertEq(market.maxReferralShare(), maxReferralShare);
    }

    function test_RevertsWhenNotAdmin() public {
        vm.expectRevert(
            "AccessControl: account 0x7fa9385be102ac3eac297483dd6233d62b3e1496 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000"
        );
        market.setMaxReferralShare(maxReferralShare);
    }
}

contract SetReferralShare is MarketPlaceTest {
    uint256 public maxReferralShare;
    uint256 public referralShare = 10;

    function setUp() public virtual override {
        super.setUp();
        maxReferralShare = market.maxReferralShare();
        assertGt(maxReferralShare, referralShare, "Max < share");
    }

    function test_setReferralShare() public {
        vm.prank(admin);
        market.setReferralShare(referralShare);

        assertEq(market.referralShare(), referralShare);
    }

    function test_RevertsWhenNotAdmin() public {
        vm.expectRevert(
            "AccessControl: account 0x7fa9385be102ac3eac297483dd6233d62b3e1496 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000"
        );
        market.setReferralShare(referralShare);
    }
}

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
