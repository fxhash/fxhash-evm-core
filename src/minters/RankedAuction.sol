// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Ownable} from "solady/src/auth/Ownable.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IRankedAuction, BidInfo, SaleInfo, LinkedList} from "src/interfaces/IRankedAuction.sol";
import {LinkedListLib} from "src/lib/LinkedListLib.sol";
import {ReserveInfo} from "src/lib/Structs.sol";

contract RankedAuction is IRankedAuction, Ownable, Pausable {
    mapping(uint256 => LinkedList) public lists;

    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintDetails) external whenNotPaused {}

    function bid(uint256 _reserveId) external payable {
        LinkedList list = lists[_reserveId];
        LinkedListLib.insert(msg.sender, msg.value, list);
        if (list.size > sale.supply) LinkedListLib.reduce(list, balances);

        emit Bid(msg.sender, msg.value, list.head, list.bids[msg.sender].next);
    }

    function settle() external onlyOwner {}

    function claim(address _bidder) external {}
}
