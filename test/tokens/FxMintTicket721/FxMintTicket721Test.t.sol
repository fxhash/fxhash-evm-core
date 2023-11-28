// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

contract FxMintTicket721Test is BaseTest {
    // State
    uint48 foreclosureTime;
    uint48 gracePeriod;
    uint80 currentPrice;
    uint80 depositAmount;
    uint80 newPrice;
    uint128 balance;
    uint256 auctionPrice;
    uint256 excessAmount;

    // Errors
    bytes4 internal FORECLOSURE_ERROR = IFxMintTicket721.Foreclosure.selector;
    bytes4 internal GRACE_PERIOD_ACTIVE_ERROR = IFxMintTicket721.GracePeriodActive.selector;
    bytes4 internal INSUFFICIENT_DEPOSIT_ERROR = IFxMintTicket721.InsufficientDeposit.selector;
    bytes4 internal INSUFFICIENT_PAYMENT_ERROR = IFxMintTicket721.InsufficientPayment.selector;
    bytes4 internal INVALID_PRICE_ERROR = IFxMintTicket721.InvalidPrice.selector;
    bytes4 internal MINT_ACTIVE_ERROR = IFxMintTicket721.MintActive.selector;
    bytes4 internal NOT_AUTHORIZED_TICKET_ERROR = IFxMintTicket721.NotAuthorized.selector;
    bytes4 internal UNAUTHORIZED_ACCOUNT_TICKET_ERROR = IFxMintTicket721.UnauthorizedAccount.selector;
    bytes4 internal UNREGISTERED_MINTER_TICKET_ERROR = IFxMintTicket721.UnregisteredMinter.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                    SET UP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _mockMinter(admin);
        _configureRoyalties();
        _configureProject(MINT_ENABLED, MAX_SUPPLY);
        _configureMinter(
            address(ticketRedeemer),
            RESERVE_START_TIME,
            RESERVE_END_TIME,
            REDEEMER_ALLOCATION,
            abi.encode(_computeTicketAddr(deployer))
        );
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, minter);
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, address(ticketRedeemer));
        _configureInit(NAME, SYMBOL, address(pseudoRandomizer), address(ipfsRenderer), tagIds);
        _createProject();
        delete mintInfo;
        _configureMinter(minter, RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION, abi.encode(PRICE));
        _createTicket();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal override {
        super._initializeState();
        amount = 1;
        tokenId = 1;
        excessAmount = DEPOSIT_AMOUNT / 2;
        newPrice = uint80(PRICE / 2);
    }

    function _setAuctionPrice() internal {
        auctionPrice = IFxMintTicket721(fxMintTicketProxy).getAuctionPrice(PRICE, foreclosureTime);
    }

    function _setBalance(address _wallet) internal {
        balance = IFxMintTicket721(fxMintTicketProxy).getBalance(_wallet);
    }

    function _setTaxInfo() internal {
        (gracePeriod, foreclosureTime, currentPrice, depositAmount) = FxMintTicket721(fxMintTicketProxy).taxes(tokenId);
    }
}
