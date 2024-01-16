// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "solady/src/auth/Ownable.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IRankedAuction} from "src/interfaces/IRankedAuction.sol";

contract RankedAuction is IRankedAuction, Ownable, Pausable {
    function setDetails() external {}

    function bid() external payable {}

    function settle() external onlyOwner {}

    function claim(address _bidder) external {}
}
