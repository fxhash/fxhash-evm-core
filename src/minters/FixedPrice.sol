// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IFxGenArt721} from "src/interfaces/IFxGenArt721.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

struct Reserve {
    uint160 allocation;
    uint40 startTime;
    uint40 endTime;
}

contract FixedPrice {
    using SafeCastLib for uint256;

    bytes32 internal constant NULL_RESERVE = keccak256(abi.encode(Reserve(0, 0, 0)));
    mapping(address => uint256[]) public prices;
    mapping(address => Reserve[]) public reserves;
    mapping(address => uint256) public saleProceeds;

    error InvalidToken();
    error InvalidPrice();
    error NotStarted();
    error Ended();
    error TooMany();

    function setMintDetails(Reserve calldata _reserve, bytes calldata _mintDetails) external {
        uint256 price = abi.decode(_mintDetails, (uint256));
        prices[msg.sender].push(price);
        reserves[msg.sender].push(_reserve);
    }

    function buyTokens(address _token, uint256 _mintId, uint256 _amount, address _to)
        external
        payable
    {
        Reserve storage reserve = reserves[_token][_mintId];
        if (NULL_RESERVE == keccak256(abi.encode(reserve))) revert InvalidToken();
        if (block.timestamp < reserve.startTime) revert NotStarted();
        if (block.timestamp > reserve.endTime) revert Ended();
        if (_amount > reserve.allocation) revert TooMany();
        uint256 price = _amount * prices[_token][_mintId];
        if (msg.value != price) revert InvalidPrice();
        reserve.allocation -= _amount.safeCastTo160();
        saleProceeds[_token] += price;
        IFxGenArt721(_token).mint(_to, _amount);
    }

    function withdraw(address _token) external {
        (, address saleReceiver) = IFxGenArt721(_token).issuerInfo();
        uint256 proceeds = saleProceeds[_token];
        delete saleProceeds[_token];
        SafeTransferLib.safeTransferETH(saleReceiver, proceeds);
    }
}
