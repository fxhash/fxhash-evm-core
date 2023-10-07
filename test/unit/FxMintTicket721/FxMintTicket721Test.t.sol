// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract FxMintTicket721Test is BaseTest {
    // State
    uint128 currentPrice;
    uint128 depositAmount;
    uint128 foreclosureTime;
    uint128 gracePeriod;
    uint128 newPrice;
    uint256 auctionPrice;
    uint256 balance;
    uint256 excessAmount;

    // Errors
    bytes4 internal FORECLOSURE_ERROR = IFxMintTicket721.Foreclosure.selector;
    bytes4 internal GRACE_PERIOD_ACTIVE_ERROR = IFxMintTicket721.GracePeriodActive.selector;
    bytes4 internal INSUFFICIENT_DEPOSIT_ERROR = IFxMintTicket721.InsufficientDeposit.selector;
    bytes4 internal INSUFFICIENT_PAYMENT_ERROR = IFxMintTicket721.InsufficientPayment.selector;
    bytes4 internal INVALID_PRICE_ERROR = IFxMintTicket721.InvalidPrice.selector;
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
        _configureSplits();
        _configureRoyalties();
        _configureProject(ENABLED, ONCHAIN, MAX_SUPPLY, CONTRACT_URI);
        _configureMinter(minter, RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION, abi.encode(PRICE));
        _configureMinter(
            address(ticketRedeemer),
            RESERVE_START_TIME,
            RESERVE_END_TIME,
            REDEEMER_ALLOCATION,
            abi.encode(_computeTicketAddr(address(this)))
        );
        _grantRole(admin, MINTER_ROLE, minter);
        _grantRole(admin, MINTER_ROLE, address(ticketRedeemer));
        _createSplit();
        _createProject();
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
        newPrice = uint128(PRICE / 2);
    }

    function _mint(address _minter, address _to, uint256 _amount, uint256 _payment) internal prank(_minter) {
        MockMinter(minter).mintTicket(fxMintTicketProxy, _to, _amount, _payment);
    }

    function _redeem(address _owner, address _ticket, uint256 _tokenId) internal prank(_owner) {
        ITicketRedeemer(ticketRedeemer).redeem(_ticket, _tokenId);
    }

    function _deposit(address _depositer, uint256 _tokenId, uint256 _amount) internal prank(_depositer) {
        IFxMintTicket721(fxMintTicketProxy).deposit{value: _amount}(_tokenId);
    }

    function _setPrice(address _owner, uint256 _tokenId, uint128 _newPrice) internal prank(_owner) {
        IFxMintTicket721(fxMintTicketProxy).setPrice(_tokenId, _newPrice);
    }

    function _claim(address _claimer, uint256 _tokenId, uint128 _newPrice, uint256 _payment) internal prank(_claimer) {
        IFxMintTicket721(fxMintTicketProxy).claim{value: _payment}(_tokenId, _newPrice);
    }

    function _setApprovalForAll(address _owner, address _operator, bool _approval) internal prank(_owner) {
        FxMintTicket721(fxMintTicketProxy).setApprovalForAll(_operator, _approval);
    }

    function _transferFrom(address _sender, address _from, address _to, uint256 _tokenId) internal prank(_sender) {
        FxMintTicket721(fxMintTicketProxy).transferFrom(_from, _to, _tokenId);
    }

    function _withdraw(address _caller, address _to) internal prank(_caller) {
        IFxMintTicket721(fxMintTicketProxy).withdraw(_to);
    }

    function _setTaxInfo() internal {
        (gracePeriod, foreclosureTime, currentPrice, depositAmount) = FxMintTicket721(fxMintTicketProxy).taxes(tokenId);
    }

    function _setAuctionPrice() internal {
        auctionPrice = IFxMintTicket721(fxMintTicketProxy).getAuctionPrice(PRICE, foreclosureTime);
    }

    function _setBalance(address _wallet) internal {
        balance = IFxMintTicket721(fxMintTicketProxy).balances(_wallet);
    }
}
