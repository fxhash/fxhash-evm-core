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
    ONE_DAY,
    SCALING_FACTOR,
    TEN_MINUTES
} from "src/utils/Constants.sol";

contract FxMintTicket721 is IFxMintTicket721, Initializable, ERC721, Ownable {
    using Strings for uint256;

    address public genArt721;
    uint48 public totalSupply;
    uint48 public gracePeriod;
    string public baseURI;
    mapping(uint256 => TaxInfo) public taxInfo;
    mapping(address => uint256) public balances;

    modifier onlyMinter() {
        if (!isMinter(msg.sender)) revert UnregisteredMinter();
        _;
    }

    modifier onlyRole(bytes32 _role) {
        address roleRegistry = IFxGenArt721(genArt721).roleRegistry();
        if (!IAccessControl(roleRegistry).hasRole(_role, msg.sender)) revert UnauthorizedAccount();
        _;
    }

    constructor(string memory _baseURI) ERC721("FxMintTicket721", "TICKET") {
        baseURI = _baseURI;
    }

    function initialize(address _genArt721, address _owner, uint48 _gracePeriod)
        external
        initializer
    {
        genArt721 = _genArt721;
        gracePeriod = _gracePeriod;
        _transferOwnership(_owner);

        emit TicketInitialized(_owner, _genArt721);
    }

    function mint(address _to, uint256 _amount) external payable onlyMinter {
        balances[owner()] += msg.value;
        uint256 listingPrice = msg.value / _amount;
        for (uint256 i; i < _amount; ++i) {
            _mint(_to, ++totalSupply);
            taxInfo[totalSupply] = TaxInfo(
                uint128(block.timestamp) + gracePeriod,
                uint128(block.timestamp) + gracePeriod,
                uint128(listingPrice),
                0
            );
        }
    }

    function burn(uint256 _tokenId) external {
        if (!_isApprovedOrOwner(msg.sender, _tokenId)) revert NotAuthorized();

        uint256 dailyTax = _getDailyTax(_tokenId);
        uint256 depositAmount = taxInfo[_tokenId].depositAmount;
        uint256 excessAmount = _getExcessTax(depositAmount, dailyTax);
        delete taxInfo[_tokenId];
        if (excessAmount > 0) balances[_ownerOf(_tokenId)] += excessAmount;
        balances[owner()] += depositAmount - excessAmount;

        _burn(_tokenId);
    }

    function setBaseURI(string calldata _uri) external onlyRole(ADMIN_ROLE) {
        baseURI = _uri;
    }

    function claim(uint256 _tokenId, uint128 _newPrice) external payable {
        TaxInfo storage tax = taxInfo[_tokenId];
        if (block.timestamp <= tax.gracePeriod) revert GracePeriodActive();
        uint256 currentPrice = tax.currentPrice;
        uint256 depositAmount = tax.depositAmount;
        uint256 foreclosureTime = tax.foreclosureTime;

        uint256 currentDailyTax = _getDailyTax(currentPrice);
        uint256 remainingDeposit =
            _calculateRemainingDeposit(currentDailyTax, foreclosureTime, depositAmount);
        uint256 depositOwed = depositAmount - remainingDeposit;

        uint256 newDailyTax = _getDailyTax(_newPrice);
        if (isForeclosed(_tokenId)) {
            uint256 auctionPrice = _getAuctionPrice(currentPrice, foreclosureTime);
            if (msg.value < auctionPrice + newDailyTax) revert InsufficientPayment();
            balances[owner()] += depositAmount + auctionPrice;
        } else {
            if (msg.value < currentPrice + newDailyTax) revert InsufficientPayment();
            balances[owner()] += depositOwed;
        }

        tax.currentPrice = _newPrice;
        tax.depositAmount = uint128(msg.value - depositOwed);
        tax.foreclosureTime =
            _calculateForeclosureTime(newDailyTax, tax.depositAmount, block.timestamp);

        address previousOwner = _ownerOf(_tokenId);
        transferFrom(previousOwner, msg.sender, _tokenId);
        balances[previousOwner] += currentPrice + remainingDeposit;
    }

    function deposit(uint256 _tokenId) public payable {
        TaxInfo storage tax = taxInfo[_tokenId];
        uint256 dailyTax = _getDailyTax(tax.currentPrice);
        if (msg.value < dailyTax) revert InsufficientDeposit();

        uint256 excessAmount = _getExcessTax(msg.value, dailyTax);
        uint256 depositAmount = msg.value - excessAmount;
        uint128 newForeclosure =
            _calculateForeclosureTime(dailyTax, tax.foreclosureTime, depositAmount);
        tax.foreclosureTime = newForeclosure;
        tax.depositAmount += uint128(depositAmount);

        emit Deposited(_tokenId, msg.sender, depositAmount, newForeclosure);

        if (excessAmount > 0) _transferFunds(msg.sender, excessAmount);
    }

    function setPrice(uint256 _tokenId, uint128 _newPrice) public {
        if (_ownerOf(_tokenId) != msg.sender) revert NotAuthorized();
        if (isForeclosed(_tokenId)) revert Foreclosure();
        if (_newPrice == 0) revert InvalidPrice(); // have minimum price

        TaxInfo storage tax = taxInfo[_tokenId];
        uint128 foreclosureTime = tax.foreclosureTime;
        uint256 currentDailyTax = _getDailyTax(tax.currentPrice);
        uint256 remainingDeposit =
            _calculateRemainingDeposit(currentDailyTax, foreclosureTime, tax.depositAmount);

        uint256 newDailyTax = _getDailyTax(_newPrice);
        if (remainingDeposit < newDailyTax) revert InsufficientDeposit();

        balances[owner()] += (tax.depositAmount - remainingDeposit);

        tax.currentPrice = _newPrice;
        tax.foreclosureTime =
            _calculateForeclosureTime(newDailyTax, remainingDeposit, foreclosureTime);
        tax.depositAmount = uint128(remainingDeposit);
    }

    function withdraw(address _to) external {
        uint256 balance = balances[_to];
        delete balances[_to];
        _transferFunds(_to, balance);
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        _requireMinted(_tokenId);
        return string.concat(baseURI, _tokenId.toString());
    }

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
        return block.timestamp > taxInfo[_tokenId].foreclosureTime;
    }

    function isMinter(address _minter) public view returns (bool) {
        return IFxGenArt721(genArt721).isMinter(_minter);
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _tokenId, uint256 _batchSize)
        internal
        virtual
        override
    {
        if (isForeclosed(_tokenId) && msg.sender != address(this)) revert Foreclosure();
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
        if (timeElapsed > ONE_DAY) return restingPrice;
        uint256 totalDecay = _currentPrice - restingPrice;
        uint256 decayedAmount = (totalDecay / ONE_DAY) * timeElapsed;
        return _currentPrice - decayedAmount;
    }

    function _calculateRemainingDeposit(
        uint256 _dailyTax,
        uint256 _foreclosureTime,
        uint256 _depositAmount
    ) internal view returns (uint256) {
        uint256 timeElapsed = _foreclosureTime - block.timestamp;
        uint256 owed = (timeElapsed * _dailyTax) / ONE_DAY;
        return _depositAmount - owed;
    }

    function _calculateForeclosureTime(
        uint256 _dailyTax,
        uint256 _taxPayment,
        uint256 _foreclosureTime
    ) internal pure returns (uint128) {
        uint256 secondsCovered = (_taxPayment * ONE_DAY) / _dailyTax;
        return uint128(_foreclosureTime + secondsCovered);
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
}
