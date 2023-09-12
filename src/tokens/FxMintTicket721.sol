// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {
    ERC721,
    ERC721URIStorage
} from "openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {IFxMintTicket721, TaxInfo} from "src/interfaces/IFxMintTicket721.sol";
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

contract FxMintTicket721 is IFxMintTicket721, ERC721URIStorage, Ownable {
    using Strings for uint256;

    string public baseURI;
    uint256 public totalSupply;
    mapping(uint256 => TaxInfo) public taxInfo;

    constructor() ERC721("FxMintTicket721", "TICKET") {}

    function mint(address _to, uint256 _amount) external {
        for (uint256 i; i < _amount; ++i) {
            _mint(_to, ++totalSupply);
            taxInfo[totalSupply] = TaxInfo(TAX_PRICE, uint128(block.timestamp));
        }
    }

    function burn(uint256 _tokenId) external {
        if (!_isApprovedOrOwner(msg.sender, _tokenId)) revert NotAuthorized();
        _burn(_tokenId);
    }

    function setBaseURI(string calldata _uri) external onlyOwner {
        baseURI = _uri;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        _requireMinted(_tokenId);
        return string.concat(baseURI, _tokenId.toString());
    }

    function getCurrentPrice(uint256 _tokenId) public view returns (uint256) {
        TaxInfo memory tax = taxInfo[_tokenId];
        return calculateExponentialDecay(
            tax.initialPrice, tax.startTime - block.timestamp, PRICE_DECAY
        );
    }

    function calculateExponentialDecay(
        uint256 _startingPrice,
        uint256 _timeElapsed,
        int256 _wadDecayRate
    ) public pure returns (uint256) {
        int256 wadDecayConstant = wadLn(ONE_WAD - _wadDecayRate);
        int256 wadDaysElapsed = toDaysWadUnsafe(_timeElapsed);
        int256 wadStartingPrice = toWadUnsafe(_startingPrice);
        return fromWad(
            wadMul(wadStartingPrice, wadExp(unsafeWadMul(wadDecayConstant, wadDaysElapsed)))
        );
    }

    function fromWad(int256 _wadValue) public pure returns (uint256) {
        return uint256(_wadValue / ONE_WAD);
    }
}
