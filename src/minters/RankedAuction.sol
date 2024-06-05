// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiUnitAuction {
    struct Bid {
        uint256 unitsRequested;
        uint256 pricePerUnit;
        bool hasWithdrawn;
    }
    address public owner;
    uint256 public auctionEndTime;
    uint256 public unitPrice;
    uint256 public totalUnits;
    uint256 public unitsSold;

    mapping(address => Bid) public bids;

    event AuctionEnded(uint256 unitPrice);
    event NewBid(address bidder, uint256 units, uint256 pricePerUnit);
    event Withdrawal(address bidder, uint256 amount);

    constructor(uint256 _biddingTime, uint256 _totalUnits) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + _biddingTime;
        totalUnits = _totalUnits;
    }

    function bid(uint256 _unitsRequested, uint256 _pricePerUnit) public payable {
        require(block.timestamp < auctionEndTime, "Auction already ended.");
        require(_unitsRequested > 0, "Units requested should be more than 0");
        require(msg.value == _unitsRequested * _pricePerUnit, "Incorrect Ether sent.");

        Bid memory existingBid = bids[msg.sender];
        bids[msg.sender] = Bid(_unitsRequested, _pricePerUnit, false);

        if (existingBid.unitsRequested > 0) {
            payable(msg.sender).transfer(existingBid.unitsRequested * existingBid.pricePerUnit);
        }

        emit NewBid(msg.sender, _unitsRequested, _pricePerUnit);
    }

    function withdraw() public {
        require(unitsSold == totalUnits, "Auction not yet ended.");
        Bid storage userBid = bids[msg.sender];
        require(!userBid.hasWithdrawn, "Already withdrawn.");

        uint256 amount = userBid.unitsRequested * unitPrice;
        userBid.hasWithdrawn = true;
        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }

    /// @notice Callback function logic for processing verified journals from Bonsai.
    function endAuction(uint256 lowestWinningBid) external {
        require(block.timestamp >= auctionEndTime, "Auction not yet ended.");
        require(unitsSold < totalUnits, "Auction already ended.");
        unitPrice = lowestWinningBid;
        emit AuctionEnded(unitPrice);
    }
}
