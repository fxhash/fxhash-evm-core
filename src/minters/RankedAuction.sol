// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Ownable} from "solady/src/auth/Ownable.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IRankedAuction, BidInfo, LinkedList, ReserveInfo, SaleInfo} from "src/interfaces/IRankedAuction.sol";
import {IToken} from "src/interfaces/IToken.sol";
import {LinkedListLib} from "src/lib/LinkedListLib.sol";

contract RankedAuction is IRankedAuction, Ownable, Pausable {
    uint256 public maxSupply;
    mapping(address => uint256) public balances;
    mapping(address => LinkedList) public lists;
    mapping(address => ReserveInfo) public reserves;
    mapping(address => SaleInfo) public sales;

    constructor(uint256 _maxSupply) {
        setMaxSupply(_maxSupply);
    }

    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintDetails) external whenNotPaused {
        if (_reserve.allocation == 0 || _reserve.allocation > maxSupply) revert InvalidAllocation();
        uint256 minReserve = abi.decode(_mintDetails, (uint256));
        reserves[msg.sender] = _reserve;
        sales[msg.sender] = SaleInfo({minReserve: minReserve});

        emit MintDetailsSet(msg.sender, _reserve, minReserve);
    }

    function bid(address _token) external payable {
        ReserveInfo memory reserve = reserves[_token];
        if (block.timestamp < reserve.startTime || block.timestamp >= reserve.endTime) revert SaleInactive();
        SaleInfo memory sale = sales[_token];
        LinkedList storage list = lists[_token];
        uint256 minBid = (list.bids[list.head].amount * 10_500) / 10_000;
        if (msg.value < sale.minReserve || (list.size == reserve.allocation && msg.value < minBid))
            revert InsufficientBid();
        uint256 amount = list.bids[msg.sender].amount;
        if (amount > 0) {
            if (msg.value <= amount) revert InsufficientBid();
            LinkedListLib.remove(msg.sender, list, balances);
        }
        uint64 extendedTime = uint64(block.timestamp + 5 minutes);
        if (reserve.endTime < extendedTime) reserve.endTime = extendedTime;
        LinkedListLib.insert(msg.sender, msg.value, list);
        if (list.size > reserve.allocation) LinkedListLib.reduce(list, balances);

        emit Bid(msg.sender, msg.value, list.head, list.bids[msg.sender].next);
    }

    function settle(address _token) external {
        ReserveInfo memory reserve = reserves[_token];
        if (block.timestamp < reserve.endTime) revert SaleNotOver();
        address owner = Ownable(_token).owner();
        if (msg.sender != owner) revert NotAuthorized();
        uint256 saleTotal = getSaleTotal(_token);

        SafeTransferLib.safeTransferETH(owner, saleTotal);
        emit Settle(msg.sender, saleTotal);
    }

    function claim(address _token, address _to) external {
        ReserveInfo memory reserve = reserves[_token];
        if (block.timestamp < reserve.endTime) revert SaleNotOver();
        LinkedList storage list = lists[_token];
        uint256 amount = list.bids[msg.sender].amount;
        if (amount == 0) revert AlreadyClaimed();
        delete list.bids[msg.sender].amount;

        IToken(_token).mint(_to, 1, amount);
        emit Claim(msg.sender, amount);
    }

    function withdraw(address _to) external {
        if (balances[_to] == 0) revert InsufficientBalance();
        uint256 balance = balances[_to];
        delete balances[_to];

        SafeTransferLib.safeTransferETH(_to, balance);
        emit Withdraw(msg.sender, _to, balance);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        emit MaxSupplyUpdated(maxSupply, _maxSupply);
        maxSupply = _maxSupply;
    }

    function timeRemaining(address _token) external view returns (uint256) {
        ReserveInfo memory reserve = reserves[_token];
        return reserve.endTime > block.timestamp ? reserve.endTime - block.timestamp : 0;
    }

    function getBidInfo(address _token, address _bidder) external view returns (uint96 amount, address nextBidder) {
        LinkedList storage list = lists[_token];
        BidInfo memory bidInfo = list.bids[_bidder];
        amount = bidInfo.amount;
        nextBidder = bidInfo.next;
    }

    function getListBids(address _token) external view returns (BidInfo[] memory bids) {
        LinkedList storage list = lists[_token];
        return LinkedListLib.getList(list);
    }

    function getPreviousBidder(address _token, address _bidder) external view returns (address) {
        LinkedList storage list = lists[_token];
        return LinkedListLib.getPrevious(_bidder, list);
    }

    function getSaleTotal(address _token) public view returns (uint256 total) {
        LinkedList storage list = lists[_token];
        address current = list.head;
        while (current != address(0)) {
            total += list.bids[current].amount;
            current = list.bids[current].next;
        }
    }
}
