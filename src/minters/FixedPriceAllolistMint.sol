// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Minter, Reserve} from "src/minters/base/Minter.sol";
import {Minted} from "src/minters/base/Minted.sol";
import {Allowlist} from "src/minters/extensions/Allowlist.sol";
import {IWETH} from "src/interfaces/IWETH.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";

/// Should refactor the merkle mint first into abstract and inherit

contract FixedPriceAllowlistMint is Minter, Allowlist {
    using SafeCastLib for uint256;

    bytes32 internal constant NULL_RESERVE = keccak256(abi.encode(Reserve(0, 0, 0)));
    mapping(address => uint256) public prices;
    mapping(address => Reserve) public reserves;
    mapping(address => uint256) public saleProceeds;

    error InvalidToken();
    error NotStarted();
    error Ended();
    error TooMany();

    function setMintDetails(Reserve calldata _reserve, bytes calldata _mintDetails) external {
        (uint256 price, bytes32 merkleRoot) = abi.decode(_mintDetails, (uint256, bytes32));
        prices[msg.sender] = price;
        reserves[msg.sender] = _reserve;
        merkleRoots[msg.sender] = merkleRoot;
    }

    function buyTokens(
        address _token,
        address _vault,
        uint256 _index,
        bytes32[] calldata _proof,
        address _to
    ) external {
        Reserve storage reserve = reserves[_token];
        if (NULL_RESERVE == keccak256(abi.encode(reserve))) revert InvalidToken();
        if (block.timestamp < reserve.startTime) revert NotStarted();
        if (block.timestamp > reserve.endTime) revert Ended();
        if (1 > reserve.allocation) revert TooMany();

        uint256 price = prices[_token];
        _claimMerkleTreeSlot(_token, _index, price, _vault, _proof);
        reserve.allocation--;
        saleProceeds[_token] += price;
        IWETH(weth9).transferFrom(msg.sender, address(this), price);
        Minted(_token).mint(1, _to);
    }

    function withdraw(address _token) external {
        address saleReceiver = Minted(_token).feeReceiver();
        uint256 proceeds = saleProceeds[_token];
        delete saleProceeds[_token];
        IWETH(weth9).transfer(saleReceiver, proceeds);
    }
}
