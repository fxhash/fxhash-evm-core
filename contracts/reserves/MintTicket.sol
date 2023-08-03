// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ERC721URIStorage, ERC721, IERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";

<<<<<<< HEAD:contracts/mint-ticket/MintTicket.sol
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "solmate/src/utils/SafeTransferLib.sol";
=======
import {IIssuer} from "contracts/interfaces/IIssuer.sol";
import {IRandomizer} from "contracts/interfaces/IRandomizer.sol";
import {IMintTicket, ProjectData, TokenData} from "contracts/interfaces/IMintTicket.sol";
>>>>>>> main:contracts/reserves/MintTicket.sol

contract MintTicket is ERC721URIStorage, Ownable, IMintTicket {
    mapping(uint256 => TokenData) public tokenData;
    mapping(address => ProjectData) public projectData;
    uint256 public lastTokenId;
    uint256 public fees;
    uint256 public availableBalance;
    uint256 public minPrice;
    IRandomizer public randomizer;

    event ProjectCreated(address issuer, uint256 gracingPeriod, string metadata);
    event TicketMinted(address issuer, address minter, uint256 price);
    event PriceUpdated(uint256 tokenId, uint256 price, uint256 coverage);
    event TaxPayed(uint256 tokenId);
    event TicketClaimed(uint256 tokenId, uint256 price, uint256 coverage, address transferTo);
    event TicketConsumed(address owner, uint256 tokenId, address issuer);

    constructor(address _randomizer) ERC721("MintTicket", "MTK") {
        randomizer = IRandomizer(_randomizer);
        lastTokenId = 0;
        fees = 0;
        availableBalance = 0;
        minPrice = 100000;
    }

    // Entry Points

    function setMinPrice(uint256 price) external onlyOwner {
        minPrice = price;
    }

    function setFees(uint256 _fees) external onlyOwner {
        fees = _fees;
    }

    function setRandomizer(address _randomizer) external onlyOwner {
        randomizer = IRandomizer(_randomizer);
    }

    receive() external payable {
        availableBalance = availableBalance + msg.value;
    }

    function withdraw(uint256 amount, address to) external onlyOwner {
        uint256 withdrawAmount = amount > 0 ? amount : availableBalance;
        require(withdrawAmount <= availableBalance, "OVER_AVAILABLE_BALANCE");
        availableBalance -= withdrawAmount;
        SafeTransferLib.safeTransferETH(to, withdrawAmount);
    }

    function createProject(uint256 _gracingPeriod, string calldata _metadata) external {
        require(projectData[msg.sender].gracingPeriod == 0, "PROJECT_EXISTS");
        require(_gracingPeriod > 0, "GRACING_UNDER_1");
        projectData[msg.sender] = ProjectData({gracingPeriod: _gracingPeriod, metadata: _metadata});
        emit ProjectCreated(msg.sender, _gracingPeriod, _metadata);
    }

    function mint(address _minter, uint256 _price) external {
        ProjectData storage project = projectData[msg.sender];
        require(project.gracingPeriod > 0, "PROJECT_DOES_NOT_EXISTS");
        uint256 tokenId = lastTokenId;
        _mint(_minter, tokenId);
        _setTokenURI(tokenId, project.metadata);
        tokenData[tokenId] = TokenData(
            msg.sender,
            _minter,
            block.timestamp,
            0,
            block.timestamp + projectData[msg.sender].gracingPeriod * 1 days,
            _price < minPrice ? minPrice : _price
        );
        lastTokenId++;
        emit TicketMinted(msg.sender, _minter, _price);
    }

    function updatePrice(uint256 tokenId, uint256 price, uint256 coverage) external payable {
        TokenData storage token = tokenData[tokenId];
        require(token.minter != address(0), "TOKEN_DOES_NOT_EXIST");
        require(isOwner(msg.sender, tokenId), "INSUFFICIENT_BALANCE");
        require(price >= minPrice, "PRICE_BELOW_MIN_PRICE");
        require(coverage > 0, "MIN_1_COVERAGE");

        uint256 daysSinceCreated = (block.timestamp - token.createdAt) / 1 days;
        uint256 startDay = token.createdAt + daysSinceCreated * 1 days;

        if (block.timestamp < token.taxationStart) {
            uint256 gracingRemainingDays = projectData[token.issuer].gracingPeriod -
                daysSinceCreated;
            require(coverage > gracingRemainingDays, "COVERAGE_GRACED");
            uint256 newDailyTax = dailyTaxAmount(price);
            uint256 taxRequiredForCoverage = newDailyTax * (coverage - gracingRemainingDays);
            uint256 totalAvailable = msg.value + token.taxationLocked;
            require(totalAvailable >= taxRequiredForCoverage, "NOT_ENOUGH_FOR_COVERAGE");

            uint256 sendBackAmount = totalAvailable - taxRequiredForCoverage;
            send(msg.sender, sendBackAmount);

            token.taxationLocked = taxRequiredForCoverage;
            token.price = price;
        } else {
            {
                uint256 daysSinceLastTaxation = (block.timestamp - token.taxationStart) / 1 days;
                uint256 dailyTax = dailyTaxAmount(token.price);
                uint256 taxToPay = dailyTax * daysSinceLastTaxation;

                payProjectAuthorsWithSplit(token.issuer, taxToPay);

                uint256 taxLeft = token.taxationLocked - taxToPay;
                uint256 newDailyTax = dailyTaxAmount(price);
                uint256 taxRequiredForCoverage = newDailyTax * coverage;
                uint256 totalAvailable = msg.value + taxLeft;

                require(totalAvailable >= taxRequiredForCoverage, "NOT_ENOUGH_FOR_COVERAGE");

                uint256 sendBackAmount = totalAvailable - taxRequiredForCoverage;
                send(msg.sender, sendBackAmount);

                token.taxationLocked = taxRequiredForCoverage;
                token.taxationStart = startDay;
                token.price = price;
            }
        }
        emit PriceUpdated(tokenId, price, coverage);
    }

    function payTax(uint256 tokenId) external payable {
        TokenData storage token = tokenData[tokenId];
        require(token.minter != address(0), "TOKEN_DOES_NOT_EXIST");
        uint256 dailyTax = dailyTaxAmount(token.price);
        uint256 daysCoverage = msg.value / dailyTax;
        uint256 cleanCoverage = dailyTax * daysCoverage;
        send(msg.sender, msg.value - cleanCoverage);
        token.taxationLocked = token.taxationLocked + cleanCoverage;
        emit TaxPayed(tokenId);
    }

    function claim(
        uint256 tokenId,
        uint256 price,
        uint256 coverage,
        address transferTo
    ) external payable {
        TokenData storage token = tokenData[tokenId];
        require(token.minter != address(0), "TOKEN_DOES_NOT_EXIST");
        require(!isGracing(tokenId), "GRACING_PERIOD");
        require(price >= minPrice, "PRICE_BELOW_MIN_PRICE");
        require(coverage > 0, "MIN_1_COVERAGE");
        address owner = ownerOf(tokenId);
        uint256 distanceFc = distanceForeclosure(tokenId);
        if (distanceFc >= 0) {
            if (distanceFc > 1 days) {
                distanceFc = 1 days;
            }
            price = foreclosurePrice(price, distanceFc);
        }

        uint256 taxAmount = dailyTaxAmount(price) * coverage;
        uint256 amountRequired = taxAmount * price;
        require(msg.value >= amountRequired, "AMOUNT_UNDER_PRICE");

        send(msg.sender, msg.value - amountRequired);
        send(owner, price);

        (uint256 taxToPay, uint256 taxToRelease) = taxRelease(tokenId);
        payProjectAuthorsWithSplit(token.issuer, taxToPay);
        send(owner, taxToRelease);
        uint256 startDay = token.createdAt +
            ((block.timestamp - token.createdAt) / 1 days) *
            1 days;
        token.taxationLocked = taxAmount;
        token.taxationStart = startDay;
        token.price = price;
        if (transferTo != address(0)) {
            safeTransferFrom(owner, transferTo, tokenId);
        }
        emit TicketClaimed(tokenId, price, coverage, transferTo);
    }

    function consume(address _owner, uint256 _tokenId, address _issuer) external payable {
        TokenData storage token = tokenData[_tokenId];
        require(token.minter != address(0), "TOKEN_DOES_NOT_EXIST");
        require(isOwner(_owner, _tokenId), "INSUFFICIENT_BALANCE");
        require(token.issuer == _issuer, "WRONG_PROJECT");
        (uint256 taxToPay, uint256 taxToRelease) = taxRelease(_tokenId);
        payProjectAuthorsWithSplit(token.issuer, taxToPay);
        send(_owner, taxToRelease);
        randomizer.generate(_tokenId);
        delete tokenData[_tokenId];
        delete projectData[_issuer];
        _burn(_tokenId);
        emit TicketConsumed(_owner, _tokenId, _issuer);
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721, IMintTicket) {
        require(isOwner(from, tokenId), "MUST_BE_OWNER");
        ERC721.transferFrom(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721, IMintTicket) {
        require(isOwner(from, tokenId));
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override(ERC721, IERC721, IMintTicket) {
        require(isOwner(from, tokenId));
        ERC721.safeTransferFrom(from, to, tokenId, data);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721URIStorage, IMintTicket) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IMintTicket).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function dailyTaxAmount(uint256 price) internal pure returns (uint256) {
        return (price * 14) / 10000;
    }

    function taxationStartDate(uint256 tokenId) internal view returns (uint256) {
        TokenData storage token = tokenData[tokenId];
        ProjectData storage project = projectData[token.issuer];
        return token.createdAt + project.gracingPeriod * 1 days;
    }

    function isGracingByTime(uint256 tokenId, uint256 time) internal view returns (bool) {
        if (taxationStartDate(tokenId) < time) {
            return false;
        } else {
            return taxationStartDate(tokenId) - time > 0;
        }
    }

    function isGracing(uint256 tokenId) internal view returns (bool) {
        return isGracingByTime(tokenId, block.timestamp);
    }

    function distanceForeclosureByTime(
        uint256 tokenId,
        uint256 time
    ) internal view returns (uint256) {
        TokenData storage token = tokenData[tokenId];
        uint256 dailyTax = dailyTaxAmount(token.price);
        uint256 daysCovered = token.taxationLocked / dailyTax;
        uint256 foreclosureTime = token.taxationStart + daysCovered * 1 days;
        return time - foreclosureTime;
    }

    function distanceForeclosure(uint256 tokenId) internal view returns (uint256) {
        return distanceForeclosureByTime(tokenId, block.timestamp);
    }

    function isForeclosureByTime(uint256 tokenId, uint256 time) internal view returns (bool) {
        TokenData storage token = tokenData[tokenId];
        uint256 dailyTax = dailyTaxAmount(token.price);
        uint256 daysCovered = token.taxationLocked / dailyTax;
        uint256 secondsSincePayment = time > token.taxationStart ? time - token.taxationStart : 0;
        uint256 daysSincePayment = secondsSincePayment / 1 days;
        return (!isGracingByTime(tokenId, time)) && (daysSincePayment >= daysCovered);
    }

    function isForeclosure(uint256 tokenId) internal view returns (bool) {
        return isForeclosureByTime(tokenId, block.timestamp);
    }

    function isOwnerByTime(
        address owner,
        uint256 tokenId,
        uint256 time
    ) internal view returns (bool) {
        return (ownerOf(tokenId) == owner) && (!isForeclosureByTime(tokenId, time));
    }

    function isOwner(address owner, uint256 tokenId) internal view returns (bool) {
        return isOwnerByTime(owner, tokenId, block.timestamp);
    }

    function send(address recipient, uint256 amount) internal {
        if (amount > 0) {
            SafeTransferLib.safeTransferETH(recipient, amount);
        }
    }

    function foreclosurePrice(
        uint256 price,
        uint256 secondsElapsed
    ) internal view returns (uint256) {
        uint256 T = (secondsElapsed * 10000) / 1 days;
        uint256 prange = price - minPrice; // TODO Check this value
        return price - (prange * T) / 10000;
    }

    function taxRelease(uint256 tokenId) internal view returns (uint256, uint256) {
        TokenData storage token = tokenData[tokenId];
        uint256 timeDiff = 0;
        if (block.timestamp > token.taxationStart) {
            timeDiff = block.timestamp - token.taxationStart;
        }
        uint256 daysSinceLastTaxation = timeDiff / 1 days;
        uint256 dailyTax = dailyTaxAmount(token.price);
        uint256 taxToPay = dailyTax * daysSinceLastTaxation;
        if (taxToPay > token.taxationLocked) {
            taxToPay = token.taxationLocked;
        }
        uint256 taxToRelease = token.taxationLocked - taxToPay;
        return (taxToPay, taxToRelease);
    }

    function payProjectAuthorsWithSplit(address _issuer, uint256 _amount) internal {
        if (_amount > 0) {
            (address receiver, uint256 royaltyAmount) = IIssuer(_issuer).primarySplitInfo(_amount);
            SafeTransferLib.safeTransferETH(receiver, royaltyAmount);
        }
    }
}
