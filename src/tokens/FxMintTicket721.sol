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
import {ONE_WAD, PRICE_DECAY, TAX_PRICE} from "src/utils/Constants.sol";

contract FxMintTicket721 is IFxMintTicket721, Initializable, ERC721, Ownable {
    using Strings for uint256;

    address public genArt721;
    uint96 public totalSupply;
    string public baseURI;
    mapping(uint256 => TaxInfo) public taxInfo;

    modifier onlyMinter() {
        if (!isMinter(msg.sender)) revert UnregisteredMinter();
        _;
    }

    constructor() ERC721("FxMintTicket721", "TICKET") {}

    function initialize(address _genArt721, address _owner) external initializer {
        genArt721 = _genArt721;
        _transferOwnership(_owner);

        emit TicketInitialized(_owner, _genArt721);
    }

    function mint(address _to, uint256 _amount) external payable {
        for (uint256 i; i < _amount; ++i) {
            _mint(_to, ++totalSupply);
            taxInfo[totalSupply] = TaxInfo(uint128(msg.value), uint128(block.timestamp));
        }
    }

    function burn(uint256 _tokenId) external {
        if (!_isApprovedOrOwner(msg.sender, _tokenId)) revert NotAuthorized();
        _burn(_tokenId);
    }

    function setBaseURI(string calldata _uri) external onlyOwner {
        baseURI = _uri;
    }

    function payTax(uint256 _tokenId) external payable {
        taxInfo[_tokenId] = TaxInfo(uint128(msg.value), uint128(block.timestamp));
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        _requireMinted(_tokenId);
        return string.concat(baseURI, _tokenId.toString());
    }

    function getCurrentPrice(uint256 _tokenId) public view returns (uint256) {
        TaxInfo memory tax = taxInfo[_tokenId];
        return _calculateExponentialDecay(
            tax.currentPrice, block.timestamp - tax.latestTime, PRICE_DECAY
        );
    }

    function isMinter(address _minter) public view returns (bool) {
        return IFxGenArt721(genArt721).isMinter(_minter);
    }

    function _update(address _to, uint256 _tokenId, address _auth)
        internal
        virtual
        returns (address)
    {
        if (getCurrentPrice(_tokenId) == 0) revert Foreclosure();
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
