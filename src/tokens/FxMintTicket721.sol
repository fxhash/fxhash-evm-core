// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IFxGenArt721, MintInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFxMintTicket721, TaxInfo} from "src/interfaces/IFxMintTicket721.sol";
import {Initializable} from "openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";
import {
    toDaysWadUnsafe,
    toWadUnsafe,
    unsafeWadMul,
    wadExp,
    wadLn,
    wadMul
} from "solmate/src/utils/SignedWadMath.sol";
import {DAILY_TAX_RATE, SCALING_FACTOR, SECONDS_IN_DAY} from "src/utils/Constants.sol";

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

    constructor() ERC721("FxMintTicket721", "TICKET") {}

    function initialize(address _genArt721, address _owner, uint48 _gracePeriod)
        external
        initializer
    {
        genArt721 = _genArt721;
        gracePeriod = _gracePeriod;
        _transferOwnership(_owner);

        emit TicketInitialized(_owner, _genArt721);
    }

    function mint(address _to, uint256 _amount) external payable {
        uint128 listingPrice = uint128(msg.value / _amount);
        for (uint256 i; i < _amount; ++i) {
            _mint(_to, ++totalSupply);
            taxInfo[totalSupply] = TaxInfo(
                uint128(block.timestamp) + gracePeriod,
                uint128(block.timestamp) + gracePeriod,
                listingPrice,
                0
            );
        }
    }

    function burn(uint256 _tokenId) external {
        if (!_isApprovedOrOwner(msg.sender, _tokenId)) revert NotAuthorized();
        _burn(_tokenId);
    }

    function setBaseURI(string calldata _uri) external onlyOwner {
        baseURI = _uri;
    }

    function claim(uint256 _tokenId, uint128 _newPrice, uint128 _days) external payable {
        if (block.timestamp <= taxInfo[_tokenId].gracePeriod) revert GracePeriodActive();
        uint128 listingPrice = taxInfo[_tokenId].listingPrice;

        if (msg.value >= listingPrice) revert InsufficientPayment();

        address previousOwner = _ownerOf(_tokenId);
        (bool success,) = previousOwner.call{value: msg.value}("");
        if (!success) revert TransferFailed();

        transferFrom(previousOwner, msg.sender, _tokenId);
        setPrice(_tokenId, _newPrice);
    }

    function deposit(uint256 _tokenId) external payable {
        TaxInfo storage tax = taxInfo[_tokenId];
        uint128 newForeclosure = tax.listingPrice + uint128(msg.value);
        tax.foreclosureTime = newForeclosure;
        tax.depositAmount += uint128(msg.value);
    }

    function setPrice(uint256 _tokenId, uint128 _newPrice) public {
        if (_ownerOf(_tokenId) != msg.sender) revert NotAuthorized();
        if (isForeclosed(_tokenId)) revert Foreclosure();
        if (_newPrice == 0) revert InvalidPrice();

        TaxInfo storage tax = taxInfo[_tokenId];
        uint128 remainingDeposit =
            _calculateRemainingDeposit(tax.listingPrice, tax.foreclosureTime, tax.depositAmount);

        tax.listingPrice = _newPrice;
        tax.foreclosureTime = _calculateForeclosureTime(_tokenId, remainingDeposit);
    }

    function withdraw(address _to) external {
        uint256 balance = balances[_to];
        delete balances[_to];

        (bool success,) = _to.call{value: balance}("");
        if (!success) revert TransferFailed();
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
        return _owner == address(this) || super.isApprovedForAll(_owner, _operator);
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
        if (isForeclosed(_tokenId) && _from == _ownerOf(_tokenId)) revert Foreclosure();
        return super._beforeTokenTransfer(_from, _to, _tokenId, _batchSize);
    }

    function _calculateForeclosureTime(uint256 _tokenId, uint256 _taxPayment)
        internal
        view
        returns (uint128)
    {
        uint256 listingPrice = taxInfo[_tokenId].listingPrice;
        uint256 dailyTax = (listingPrice * DAILY_TAX_RATE) / SCALING_FACTOR;
        uint256 timeCovered = (_taxPayment * SECONDS_IN_DAY) / dailyTax;
        return taxInfo[_tokenId].foreclosureTime + uint128(timeCovered);
    }

    function _calculateRemainingDeposit(
        uint128 _listingPrice,
        uint128 _foreclosureTime,
        uint128 _depositAmount
    ) internal view returns (uint128) {
        uint256 timeElapsed = _foreclosureTime - block.timestamp;
        uint256 dailyTax = (_listingPrice * DAILY_TAX_RATE) / SCALING_FACTOR;
        uint256 owed = timeElapsed * dailyTax;
        return _depositAmount - uint128(owed);
    }
}
