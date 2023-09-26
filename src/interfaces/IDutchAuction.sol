// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IMinter} from "src/interfaces/IMinter.sol";

interface IDutchAuction is IMinter {
    error AddressZero();
    error Ended();
    error InvalidAllocation();
    error InvalidPayment();
    error InvalidPrice();
    error InvalidStep();
    error InvalidTimes();
    error InvalidToken();
    error InsufficientPrice();
    error InsufficientFunds();
    error NotStarted();
    error TooMany();
}
