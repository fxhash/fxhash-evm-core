// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IMintTicket {
    function burn(uint256) external;
    /// need to implement harberger taxes
}
