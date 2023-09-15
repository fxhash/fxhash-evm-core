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
import {ONE_DAY, ONE_WAD, PRICE_DECAY} from "src/utils/Constants.sol";

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
        for (uint256 i; i < _amount; ++i) {
            _mint(_to, ++totalSupply);
            taxInfo[totalSupply] =
                TaxInfo(uint64(msg.value), uint64(block.timestamp) + gracePeriod, 0);
        }
    }

    function burn(uint256 _tokenId) external {
        if (!_isApprovedOrOwner(msg.sender, _tokenId)) revert NotAuthorized();
        _burn(_tokenId);
    }

    function setBaseURI(string calldata _uri) external onlyOwner {
        baseURI = _uri;
    }

    function claim(uint256 _tokenId, uint64 _newPrice, uint64 _days) external payable {
        // if (taxInfo[_tokenId].gracePeriod) revert GracePeriodActive();
        if (msg.value >= taxInfo[_tokenId].currentPrice) revert InsufficientPayment();

        address previousOwner = _ownerOf(_tokenId);
        (bool success,) = previousOwner.call{value: msg.value}("");
        if (!success) revert TransferFailed();

        transferFrom(previousOwner, msg.sender, _tokenId);
        setPrice(_tokenId, _newPrice, _days);
    }

    function deposit(uint256 _tokenId) external payable {
        uint64 newForeclosure = taxInfo[_tokenId].currentPrice + uint64(msg.value);
        taxInfo[_tokenId].foreclosure = newForeclosure;
    }

    function setPrice(uint256 _tokenId, uint64 _newPrice, uint64 _days) public payable {
        if (_ownerOf(_tokenId) != msg.sender) revert NotAuthorized();
        if (_newPrice == 0) revert InvalidPrice();
        if (_days == 0) revert InvalidDuration();

        TaxInfo storage tax = taxInfo[_tokenId];
        tax.currentPrice = _newPrice;
        tax.foreclosure = uint64(block.timestamp) + (_days * ONE_DAY);
        tax.depositAmount += uint120(msg.value);
    }

    function withdraw(address _to) external {
        uint256 balance = balances[_to];
        delete balances[_to];

        (bool success,) = _to.call{value: balance}("");
        if (!success) revert TransferFailed();
    }

    function getCurrentPrice(uint256 _tokenId) public view returns (uint256) {
        TaxInfo memory tax = taxInfo[_tokenId];
        return _calculateExponentialDecay(
            tax.currentPrice, block.timestamp - tax.foreclosure, PRICE_DECAY
        );
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
        return block.timestamp > taxInfo[_tokenId].foreclosure;
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

    function _calculateExponentialDecay(
        uint256 _startingPrice,
        uint256 _timeElapsed,
        int256 _wadDecayRate
    ) internal pure returns (uint256) {
        int256 wadDecayConstant = wadLn(ONE_WAD - _wadDecayRate);
        int256 wadDaysElapsed = toDaysWadUnsafe(_timeElapsed);
        int256 wadStartingPrice = toWadUnsafe(_startingPrice);
        return _fromWad(
            wadMul(wadStartingPrice, wadExp(unsafeWadMul(wadDecayConstant, wadDaysElapsed)))
        );
    }

    function _fromWad(int256 _wadValue) internal pure returns (uint256) {
        return uint256(_wadValue / ONE_WAD);
    }
}
