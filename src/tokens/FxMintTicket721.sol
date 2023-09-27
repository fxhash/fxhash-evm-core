// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IAccessControl} from "openzeppelin/contracts/access/IAccessControl.sol";
import {IFxGenArt721, MintInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFxMintTicket721, TaxInfo} from "src/interfaces/IFxMintTicket721.sol";
import {Initializable} from "openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

import {
    ADMIN_ROLE,
    AUCTION_DECAY_RATE,
    DAILY_TAX_RATE,
    MINIMUM_PRICE,
    ONE_DAY,
    SCALING_FACTOR,
    TEN_MINUTES
} from "src/utils/Constants.sol";

import "forge-std/Test.sol";

contract FxMintTicket721 is IFxMintTicket721, Initializable, ERC721, Ownable {
    using Strings for uint256;

    address public genArt721;
    uint48 public totalSupply;
    uint48 public gracePeriod;
    string public baseURI;
    mapping(address => uint256) public balances;
    mapping(uint256 => TaxInfo) public taxes;

    /*//////////////////////////////////////////////////////////////////////////
                                  MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    modifier onlyMinter() {
        if (!isMinter(msg.sender)) revert UnregisteredMinter();
        _;
    }

    modifier onlyRole(bytes32 _role) {
        address roleRegistry = IFxGenArt721(genArt721).roleRegistry();
        if (!IAccessControl(roleRegistry).hasRole(_role, msg.sender)) revert UnauthorizedAccount();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(string memory _baseURI) ERC721("FxMintTicket721", "TICKET") {
        baseURI = _baseURI;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INITIALIZATION
    //////////////////////////////////////////////////////////////////////////*/

    function initialize(address _owner, address _genArt721, uint48 _gracePeriod)
        external
        initializer
    {
        genArt721 = _genArt721;
        gracePeriod = _gracePeriod;
        _transferOwnership(_owner);

        emit TicketInitialized(_genArt721, _gracePeriod);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function mint(address _to, uint256 _amount, uint256 _payment) external onlyMinter {
        // Calculates listing price per token
        uint256 listingPrice = _payment / _amount;

        unchecked {
            for (uint256 i; i < _amount; ++i) {
                // Increments supply and mints token to given wallet
                _mint(_to, ++totalSupply);

                // Sets initial tax info of token
                taxes[totalSupply] = TaxInfo(
                    uint128(block.timestamp) + gracePeriod,
                    uint128(block.timestamp) + gracePeriod,
                    uint128(listingPrice),
                    0
                );
            }
        }
    }

    function burn(uint256 _tokenId) external onlyMinter {
        // Reverts if caller is not owner or approved
        if (!_isApprovedOrOwner(msg.sender, _tokenId)) revert NotAuthorized();

        // Loads current tax info
        TaxInfo memory taxInfo = taxes[_tokenId];

        // Deletes tax info of token
        delete taxes[_tokenId];

        // Gets current daily tax amount
        uint256 dailyTax = _getDailyTax(taxInfo.currentPrice);
        // Gets excess amount of taxes paid
        uint256 excessTax = _getExcessTax(taxInfo.depositAmount, dailyTax);

        // Updates balance of token owner with any excess tax amount
        if (excessTax > 0) balances[_ownerOf(_tokenId)] += excessTax;
        // Updates balance of contract owner with deposit amount owed
        balances[owner()] += taxInfo.depositAmount - excessTax;

        // Burns token
        _burn(_tokenId);
    }

    function claim(uint256 _tokenId, uint128 _newPrice) external payable {
        // Loads current tax info
        TaxInfo storage taxInfo = taxes[_tokenId];
        // Reverts if grace period of token is still active
        if (block.timestamp <= taxInfo.gracePeriod) revert GracePeriodActive();
        uint256 currentPrice = taxInfo.currentPrice;
        uint256 totalDeposit = taxInfo.depositAmount;
        uint256 foreclosureTime = taxInfo.foreclosureTime;

        // Gets current daily tax amount for current price
        uint256 currentDailyTax = _getDailyTax(currentPrice);
        // Gets remaining deposit amount for current price
        uint256 remainingDeposit =
            _getRemainingDeposit(currentDailyTax, foreclosureTime, totalDeposit);
        // Calculates deposit amount owed for current price
        uint256 depositOwed = totalDeposit - remainingDeposit;

        // Gets new daily tax amount for new price
        uint256 newDailyTax = _getDailyTax(_newPrice);

        // Checks if foreclosure is active
        if (isForeclosed(_tokenId)) {
            // Gets current auction price
            uint256 auctionPrice = _getAuctionPrice(currentPrice, foreclosureTime);
            // Reverts if payment amount is insufficient to auction price and new daily tax
            if (msg.value < auctionPrice + newDailyTax) revert InsufficientPayment();
            // Updates balance of contract owner
            balances[owner()] += totalDeposit + auctionPrice;
            // Sets new deposit amount based on auction price
            taxInfo.depositAmount = uint128(msg.value - auctionPrice);
        } else {
            // Reverts if payment amount if insufficient to current price and new daily tax
            if (msg.value < currentPrice + newDailyTax) revert InsufficientPayment();
            // Updates balance of contract owner
            balances[owner()] += depositOwed;
            // Sets new deposit amount based on current price
            taxInfo.depositAmount = uint128(msg.value - currentPrice);
        }

        // Sets new tax info
        taxInfo.currentPrice = _newPrice;
        taxInfo.foreclosureTime =
            _getForeclosureTime(newDailyTax, taxInfo.depositAmount, block.timestamp);

        // Transfers token from previous owner to new owner
        address previousOwner = _ownerOf(_tokenId);
        transferFrom(previousOwner, msg.sender, _tokenId);

        // Updates balance of previous token owner
        balances[previousOwner] += currentPrice + remainingDeposit;

        // Emits event for claiming ticket
        emit Claimed(_tokenId, msg.sender, _newPrice, msg.value);
    }

    function deposit(uint256 _tokenId) public payable {
        // Loads current tax info
        TaxInfo storage taxInfo = taxes[_tokenId];
        // Gets current daily tax amount
        uint256 dailyTax = _getDailyTax(taxInfo.currentPrice);
        // Reverts if deposit amount is less than daily tax amount for one day
        if (msg.value < dailyTax) revert InsufficientDeposit();

        // Gets excess daily tax amount
        uint256 excessAmount = _getExcessTax(msg.value, dailyTax);
        // Calculates total deposit amount
        uint256 depositAmount = msg.value - excessAmount;
        // Gets new foreclosure time based on deposit amount
        uint128 newForeclosure =
            _getForeclosureTime(dailyTax, taxInfo.foreclosureTime, depositAmount);

        // Sets new tax info
        taxInfo.foreclosureTime = newForeclosure;
        taxInfo.depositAmount += uint128(depositAmount);

        // Emits event for depositing taxes
        emit Deposited(_tokenId, msg.sender, depositAmount, newForeclosure);

        // Transfers any excess tax amount back to depositer
        if (excessAmount > 0) _transferFunds(msg.sender, excessAmount);
    }

    function setPrice(uint256 _tokenId, uint128 _newPrice) public {
        // Reverts if caller is not owner of token
        if (_ownerOf(_tokenId) != msg.sender) revert NotAuthorized();
        // Reverts if token is foreclosed
        if (isForeclosed(_tokenId)) revert Foreclosure();
        // Reverts if new price is less than the minimum price
        if (_newPrice < MINIMUM_PRICE) revert InvalidPrice();

        // Initializes tax info
        TaxInfo storage taxInfo = taxes[_tokenId];
        uint128 foreclosureTime = taxInfo.foreclosureTime;

        // Gets daily tax amount for current price
        uint256 currentDailyTax = _getDailyTax(taxInfo.currentPrice);
        // Gets remaining deposit amount for current price
        uint256 remainingDeposit =
            _getRemainingDeposit(currentDailyTax, foreclosureTime, taxInfo.depositAmount);

        // Gets new daily tax amount for new price
        uint256 newDailyTax = _getDailyTax(_newPrice);

        // Reverts if remaining deposit amount is insufficient to new daily tax amount
        if (remainingDeposit < newDailyTax) revert InsufficientDeposit();

        // Updates balance of contract owner with deposit amount owed
        balances[owner()] += (taxInfo.depositAmount - remainingDeposit);

        // Sets new tax info
        taxInfo.currentPrice = _newPrice;
        taxInfo.foreclosureTime =
            _getForeclosureTime(newDailyTax, foreclosureTime, remainingDeposit);
        taxInfo.depositAmount = uint128(remainingDeposit);

        // Emits event for setting new price
        emit SetPrice(_tokenId, msg.sender, _newPrice);
    }

    function withdraw(address _to) external {
        uint256 balance = balances[_to];
        delete balances[_to];
        _transferFunds(_to, balance);

        // Emits event for withdrawing balance
        emit Withdraw(msg.sender, _to, balance);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function setBaseURI(string calldata _uri) external onlyRole(ADMIN_ROLE) {
        baseURI = _uri;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                READ FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operator == address(this) || super.isApprovedForAll(_owner, _operator);
    }

    function isForeclosed(uint256 _tokenId) public view returns (bool) {
        return block.timestamp >= taxes[_tokenId].foreclosureTime;
    }

    function isMinter(address _minter) public view returns (bool) {
        return IFxGenArt721(genArt721).isMinter(_minter);
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        _requireMinted(_tokenId);
        return string.concat(baseURI, _tokenId.toString());
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _beforeTokenTransfer(address _from, address _to, uint256 _tokenId, uint256 _batchSize)
        internal
        virtual
        override
    {
        // Check if token is being minted
        if (_from != address(0)) {
            // Reverts if token is foreclosed and caller is not this contract
            if (isForeclosed(_tokenId) && msg.sender != address(this)) revert Foreclosure();
            // Reverts if token is not foreclosed and caller is not owner of token
            if (!isForeclosed(_tokenId) && _from != msg.sender) revert NotAuthorized();
        }

        return super._beforeTokenTransfer(_from, _to, _tokenId, _batchSize);
    }

    function _transferFunds(address _to, uint256 _amount) internal {
        (bool success,) = _to.call{value: _amount}("");
        if (!success) revert TransferFailed();
    }

    function _getAuctionPrice(uint256 _currentPrice, uint256 _foreclosureTime)
        internal
        view
        returns (uint256)
    {
        uint256 timeElapsed = block.timestamp - _foreclosureTime;
        uint256 restingPrice = (_currentPrice * AUCTION_DECAY_RATE) / SCALING_FACTOR;
        // Returns resting price if more than one day has already passed
        if (timeElapsed > ONE_DAY) return restingPrice;
        uint256 totalDecay = _currentPrice - restingPrice;
        uint256 decayedAmount = (totalDecay / ONE_DAY) * timeElapsed;
        return _currentPrice - decayedAmount;
    }

    function _getRemainingDeposit(
        uint256 _dailyTax,
        uint256 _foreclosureTime,
        uint256 _depositAmount
    ) internal view returns (uint256) {
        uint256 depositEndTime = _foreclosureTime - _getTaxDuration(_depositAmount, _dailyTax);
        if (block.timestamp <= depositEndTime) return _depositAmount;
        uint256 elapsedDuration = block.timestamp - depositEndTime;
        uint256 amountOwed = (elapsedDuration * _dailyTax) / ONE_DAY;
        return _depositAmount - amountOwed;
    }

    function _getDailyTax(uint256 _currentPrice) internal pure returns (uint256) {
        return (_currentPrice * DAILY_TAX_RATE) / SCALING_FACTOR;
    }

    function _getExcessTax(uint256 _totalDeposit, uint256 _dailyTax)
        internal
        pure
        returns (uint256)
    {
        uint256 daysCovered = _totalDeposit / _dailyTax;
        uint256 totalAmount = daysCovered * _dailyTax;
        return _totalDeposit - totalAmount;
    }

    function _getForeclosureTime(uint256 _dailyTax, uint256 _foreclosureTime, uint256 _taxPayment)
        internal
        pure
        returns (uint128)
    {
        uint256 secondsCovered = _getTaxDuration(_taxPayment, _dailyTax);
        return uint128(_foreclosureTime + secondsCovered);
    }

    function _getTaxDuration(uint256 _taxPayment, uint256 _dailyTax)
        internal
        pure
        returns (uint256)
    {
        return (_taxPayment * ONE_DAY) / _dailyTax;
    }
}
