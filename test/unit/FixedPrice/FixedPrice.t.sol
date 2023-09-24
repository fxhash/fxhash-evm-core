// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/BaseTest.t.sol";
import {IFixedPrice} from "src/interfaces/IFixedPrice.sol";
import {FixedPrice} from "src/minters/FixedPrice.sol";

contract FixedPriceTest is BaseTest {
    FixedPrice internal sale;
    uint96 internal price = 1 ether;

    bytes4 internal TOO_MANY_ERROR = IFixedPrice.TooMany.selector;
    bytes4 internal INVALID_PAYMENT_ERROR = IFixedPrice.InvalidPayment.selector;
    bytes4 internal INVALID_PRICE_ERROR = IFixedPrice.InvalidPrice.selector;
    bytes4 internal INVALID_AMOUNT_ERROR = IFixedPrice.InvalidPrice.selector;
    bytes4 internal INVALID_TIMES_ERROR = IFixedPrice.InvalidTimes.selector;
    bytes4 internal INVALID_TOKEN_ERROR = IFixedPrice.InvalidToken.selector;
    bytes4 internal INVALID_ALLOCATION_ERROR = IFixedPrice.InvalidAllocation.selector;
    bytes4 internal ENDED_ERROR = IFixedPrice.Ended.selector;
    bytes4 internal NOT_STARTED_ERROR = IFixedPrice.NotStarted.selector;
    bytes4 internal ADDRESS_ZERO_ERROR = IFixedPrice.AddressZero.selector;
    bytes4 internal INSUFFICIENT_FUNDS_ERROR = IFixedPrice.InsufficientFunds.selector;

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
