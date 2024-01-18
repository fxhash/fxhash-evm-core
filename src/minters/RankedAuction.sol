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

    function settle() external {
        if (block.timestamp < sale.endTime) revert SaleNotOver();
        address owner = owner();
        uint256 saleTotal = getSaleTotal();
        _transferRemaining(owner);

        emit Settle(owner, sale);
    }

    function claim(address _bidder) external {}

    function _transferRemaining(address _owner) internal {
        uint256 size = uint256(list.size);
        uint256 supply = uint256(sale.supply);
        uint256 startId = uint256(sale.startId);

        if (size < supply) {
            address nft = sale.nft;
            uint256 unsold = supply - size;
            uint256 start = (supply - unsold) + startId;
            uint256 end = (supply - 1) + startId;
            unchecked {
                for (uint256 i = start; i <= end; ++i) {
                    IERC721(nft).safeTransferFrom(address(this), _owner, i);
                }
            }
        }
    }
}
