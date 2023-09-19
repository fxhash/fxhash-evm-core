// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/BaseTest.t.sol";
import {IFixedPrice} from "src/interfaces/IFixedPrice.sol";
import {FixedPrice} from "src/minters/FixedPrice.sol";
import {ReserveInfo} from "src/interfaces/IFxGenArt721.sol";

contract FixedPriceTest is BaseTest {
    FixedPrice internal sale;
    uint96 internal price = 1 ether;

    bytes4 internal immutable ERROR_TOO_MANY = IFixedPrice.TooMany.selector;
    bytes4 internal immutable ERROR_INVALID_PAYMENT = IFixedPrice.InvalidPayment.selector;
    bytes4 internal immutable ERROR_INVALID_PRICE = IFixedPrice.InvalidPrice.selector;
    bytes4 internal immutable ERROR_INVALID_AMOUNT = IFixedPrice.InvalidPrice.selector;
    bytes4 internal immutable ERROR_INVALID_TIMES = IFixedPrice.InvalidTimes.selector;
    bytes4 internal immutable ERROR_INVALID_TOKEN = IFixedPrice.InvalidToken.selector;
    bytes4 internal immutable ERROR_INVALID_ALLOCATION = IFixedPrice.InvalidAllocation.selector;
    bytes4 internal immutable ERROR_ENDED = IFixedPrice.Ended.selector;
    bytes4 internal immutable ERROR_NOT_STARTED = IFixedPrice.NotStarted.selector;
    bytes4 internal immutable ERROR_ADDRESS_ZERO = IFixedPrice.AddressZero.selector;
    bytes4 internal immutable ERROR_INSUFFICIENT_FUNDS = IFixedPrice.InsufficientFunds.selector;

    function setUp() public override {
        super.setUp();
        vm.deal(address(this), INITIAL_BALANCE);
        sale = new FixedPrice();
        _configureGenArtToken(creator, admin, address(sale));
        vm.warp(RESERVE_START_TIME);
    }

    function _configureGenArtToken(address _creator, address _admin, address _sale) internal {
        vm.prank(admin);
        fxRoleRegistry.grantRole(MINTER_ROLE, _sale);
        projectInfo.supply = RESERVE_MINTER_ALLOCATION;
        mintInfo.push(
            MintInfo(
                address(sale),
                ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, RESERVE_MINTER_ALLOCATION),
                abi.encode(price)
            )
        );
        vm.startPrank(creator);
        fxGenArtProxy = fxIssuerFactory.createProject(
            _creator, _creator, projectInfo, metadataInfo, mintInfo, royaltyReceivers, basisPoints
        );
        FxGenArt721(fxGenArtProxy).toggleMint();
        vm.stopPrank();

        _setRandomizer(_admin, address(fxPseudoRandomizer));
    }
}
