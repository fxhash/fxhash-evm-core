// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IMinter} from "contracts/interfaces/IMinter.sol";
import {Minted} from "contracts/minters/Minted.sol";

contract FixedPriceMint is IMinter {
    mapping(address => uint256) public price;

    function setMintDetails(uint256, uint256, uint256, bytes calldata) external {}

    function mint(address _token, address _to) external {
        Minted(_token).mint(1, _to);
    }
}
