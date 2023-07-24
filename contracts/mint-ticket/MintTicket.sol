// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/interfaces/IIssuer.sol";
import "contracts/interfaces/IRandomizer.sol";
import "contracts/interfaces/IMintTicket.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@rari-capital/solmate/src/utils/SafeTransferLib.sol";
import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";

contract MintTicket is Ownable, IMintTicket {
    mapping(address => uint256) public tickets;
    mapping(uint256 => TicketData) public userTickets;
    uint256 public lastTicketId;
    uint256 public fees;
    uint256 public availableBalance;
    uint256 public minPrice;
    IRandomizer public randomizer;

    event TicketCreated(address issuer, uint256 gracingPeriod);
    event TicketMinted(address issuer, address minter, uint256 price);
    event PriceUpdated(uint256 tokenId, uint256 price, uint256 coverage);
    event TaxPayed(uint256 tokenId);
    event TicketClaimed(uint256 tokenId, uint256 price, uint256 coverage, address transferTo);
    event TicketConsumed(address owner, uint256 tokenId, address issuer);

    constructor(address _randomizer, uint256 _fees, uint256 _minPrice) {
        randomizer = IRandomizer(_randomizer);
        fees = _fees;
        minPrice = _minPrice;
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

    function createTicket(uint256 _gracingPeriod) external {
        require(tickets[msg.sender] == 0, "PROJECT_EXISTS");
        require(_gracingPeriod > 0, "GRACING_UNDER_1");
        tickets[msg.sender] = _gracingPeriod;
        emit TicketCreated(msg.sender, _gracingPeriod);
    }

    function mintTicket(address _minter, uint256 _price) external {
        uint256 gracingPeriod = tickets[msg.sender];
        require(gracingPeriod > 0, "PROJECT_DOES_NOT_EXISTS");
        userTickets[lastTicketId] = TicketData(
            msg.sender,
            _minter,
            block.timestamp,
            0,
            block.timestamp + gracingPeriod * 1 days,
            _price < minPrice ? minPrice : _price
        );
        lastTicketId++;
        emit TicketMinted(msg.sender, _minter, _price);
    }

    function updatePrice(uint256 ticketId, uint256 price, uint256 coverage) external payable {
        TicketData storage userTicket = userTickets[ticketId];
        uint256 gracingPeriod = tickets[userTicket.issuer];
        require(userTicket.createdAt > 0, "USER_TICKET_DOES_NOT_EXIST");
        require(gracingPeriod > 0, "TICKET_DOES_NOT_EXIST");
        require(price >= minPrice, "PRICE_BELOW_MIN_PRICE");
        require(coverage > 0, "MIN_1_COVERAGE");
        require(userTicket.owner == msg.sender, "CALLER_NOT_OWNER");
        uint256 daysSinceCreated = (block.timestamp - userTicket.createdAt) / 1 days;
        uint256 startDay = userTicket.createdAt + daysSinceCreated * 1 days;

        if (block.timestamp < userTicket.taxationStart) {
            uint256 gracingRemainingDays = gracingPeriod - daysSinceCreated;
            require(coverage > gracingRemainingDays, "COVERAGE_GRACED");
            uint256 newDailyTax = dailyTaxAmount(price);
            uint256 taxRequiredForCoverage = newDailyTax * (coverage - gracingRemainingDays);
            uint256 totalAvailable = msg.value + userTicket.taxationLocked;
            require(totalAvailable >= taxRequiredForCoverage, "NOT_ENOUGH_FOR_COVERAGE");

            uint256 sendBackAmount = totalAvailable - taxRequiredForCoverage;

            send(msg.sender, sendBackAmount);

            userTicket.taxationLocked = taxRequiredForCoverage;
            userTicket.price = price;
        } else {
            {
                uint256 daysSinceLastTaxation = (block.timestamp - userTicket.taxationStart) /
                    1 days;
                uint256 dailyTax = dailyTaxAmount(userTicket.price);
                uint256 taxToPay = dailyTax * daysSinceLastTaxation;

                payProjectAuthorsWithSplit(userTicket.issuer, taxToPay);
                require(userTicket.taxationLocked >= taxToPay, "INSUFFICIENT_TAX_PAID");
                uint256 taxLeft = userTicket.taxationLocked - taxToPay;
                uint256 newDailyTax = dailyTaxAmount(price);

                uint256 taxRequiredForCoverage = newDailyTax * coverage;

                uint256 totalAvailable = msg.value + taxLeft;

                require(totalAvailable >= taxRequiredForCoverage, "NOT_ENOUGH_FOR_COVERAGE");

                uint256 sendBackAmount = totalAvailable - taxRequiredForCoverage;

                send(msg.sender, sendBackAmount);

                userTicket.taxationLocked = taxRequiredForCoverage;
                userTicket.taxationStart = startDay;
                userTicket.price = price;
            }
        }
        emit PriceUpdated(ticketId, price, coverage);
    }

    function payTax(uint256 ticketId) external payable {
        TicketData storage userTicket = userTickets[ticketId];
        require(userTicket.createdAt > 0, "USER_TICKET_DOES_NOT_EXIST");
        uint256 dailyTax = dailyTaxAmount(userTicket.price);
        uint256 daysCoverage = msg.value / dailyTax;
        uint256 cleanCoverage = dailyTax * daysCoverage;
        send(msg.sender, msg.value - cleanCoverage);
        userTicket.taxationLocked = userTicket.taxationLocked + cleanCoverage;
        emit TaxPayed(ticketId);
    }

    function claim(
        uint256 ticketId,
        uint256 price,
        uint256 coverage,
        address transferTo
    ) external payable {
        TicketData storage userTicket = userTickets[ticketId];
        address owner = userTicket.owner;
        require(userTicket.createdAt > 0, "USER_TICKET_DOES_NOT_EXIST");
        require(!isGracing(ticketId), "GRACING_PERIOD");
        require(price >= minPrice, "PRICE_BELOW_MIN_PRICE");
        require(coverage > 0, "MIN_1_COVERAGE");
        require(msg.sender == owner, "CALLER_NOT_OWNER");
        uint256 distanceFc = distanceForeclosure(ticketId);
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

        (uint256 taxToPay, uint256 taxToRelease) = taxRelease(ticketId);
        payProjectAuthorsWithSplit(userTicket.issuer, taxToPay);
        send(owner, taxToRelease);
        uint256 startDay = userTicket.createdAt +
            ((block.timestamp - userTicket.createdAt) / 1 days) *
            1 days;
        userTicket.taxationLocked = taxAmount;
        userTicket.taxationStart = startDay;
        userTicket.price = price;
        if (transferTo != address(0)) {
            userTicket.owner = transferTo;
        }
        emit TicketClaimed(ticketId, price, coverage, transferTo);
    }

    function consume(address _owner, uint256 _ticketId, address _issuer) external payable {
        TicketData storage userTicket = userTickets[_ticketId];
        require(userTicket.createdAt > 0, "USER_TICKET_DOES_NOT_EXIST");
        require(userTicket.issuer == _issuer, "WRONG_PROJECT");
        (uint256 taxToPay, uint256 taxToRelease) = taxRelease(_ticketId);
        payProjectAuthorsWithSplit(userTicket.issuer, taxToPay);
        send(_owner, taxToRelease);
        randomizer.generate(_ticketId);
        delete userTickets[_ticketId];
        delete tickets[_issuer];
        emit TicketConsumed(_owner, _ticketId, _issuer);
    }

    function dailyTaxAmount(uint256 price) internal pure returns (uint256) {
        return (price * 14) / 10000;
    }

    function taxationStartDate(uint256 ticketId) internal view returns (uint256) {
        TicketData storage userTicket = userTickets[ticketId];
        uint256 gracingPeriod = tickets[userTicket.issuer];
        require(gracingPeriod > 0, "TICKET_DOES_NOT_EXIST");
        return userTicket.createdAt + gracingPeriod * 1 days;
    }

    function isGracingByTime(uint256 ticketId, uint256 time) internal view returns (bool) {
        if (taxationStartDate(ticketId) < time) {
            return false;
        } else {
            return taxationStartDate(ticketId) - time > 0;
        }
    }

    function isGracing(uint256 ticketId) internal view returns (bool) {
        return isGracingByTime(ticketId, block.timestamp);
    }

    function distanceForeclosureByTime(
        uint256 _ticketId,
        uint256 _time
    ) internal view returns (uint256) {
        TicketData storage userTicket = userTickets[_ticketId];
        uint256 dailyTax = dailyTaxAmount(userTicket.price);
        uint256 daysCovered = userTicket.taxationLocked / dailyTax;
        uint256 foreclosureTime = userTicket.taxationStart + daysCovered * 1 days;
        return _time - foreclosureTime;
    }

    function distanceForeclosure(uint256 _ticketId) internal view returns (uint256) {
        return distanceForeclosureByTime(_ticketId, block.timestamp);
    }

    function isForeclosureByTime(uint256 _ticketId, uint256 _time) internal view returns (bool) {
        TicketData storage userTicket = userTickets[_ticketId];
        uint256 dailyTax = dailyTaxAmount(userTicket.price);
        uint256 daysCovered = userTicket.taxationLocked / dailyTax;
        uint256 secondsSincePayment = _time > userTicket.taxationStart
            ? _time - userTicket.taxationStart
            : 0;
        uint256 daysSincePayment = secondsSincePayment / 1 days;
        return (!isGracingByTime(_ticketId, _time)) && (daysSincePayment >= daysCovered);
    }

    function isForeclosure(uint256 _ticketId) internal view returns (bool) {
        return isForeclosureByTime(_ticketId, block.timestamp);
    }

    function isOwnerByTime(
        uint256 _ticketId,
        address _owner,
        uint256 _time
    ) internal view returns (bool) {
        return (userTickets[_ticketId].owner == _owner) && (!isForeclosureByTime(_ticketId, _time));
    }

    function isOwner(address _owner, uint256 _ticketId) internal view returns (bool) {
        return isOwnerByTime(_ticketId, _owner, block.timestamp);
    }

    function send(address _recipient, uint256 _amount) internal {
        if (_amount > 0) {
            SafeTransferLib.safeTransferETH(_recipient, _amount);
        }
    }

    function foreclosurePrice(
        uint256 _price,
        uint256 _secondsElapsed
    ) internal view returns (uint256) {
        uint256 T = (_secondsElapsed * 10000) / 1 days;
        uint256 prange = _price - minPrice; // TODO Check this value
        return _price - (prange * T) / 10000;
    }

    function taxRelease(uint256 _ticketId) internal view returns (uint256, uint256) {
        TicketData storage userTicket = userTickets[_ticketId];
        uint256 timeDiff = 0;
        if (block.timestamp > userTicket.taxationStart) {
            timeDiff = block.timestamp - userTicket.taxationStart;
        }
        uint256 daysSinceLastTaxation = timeDiff / 1 days;
        uint256 dailyTax = dailyTaxAmount(userTicket.price);
        uint256 taxToPay = dailyTax * daysSinceLastTaxation;
        if (taxToPay > userTicket.taxationLocked) {
            taxToPay = userTicket.taxationLocked;
        }
        uint256 taxToRelease = userTicket.taxationLocked - taxToPay;
        return (taxToPay, taxToRelease);
    }

    function payProjectAuthorsWithSplit(address _issuer, uint256 _amount) internal {
        if (_amount > 0) {
            (address receiver, uint256 royaltyAmount) = IIssuer(_issuer).primarySplitInfo(_amount);
            SafeTransferLib.safeTransferETH(receiver, royaltyAmount);
        }
    }
}
