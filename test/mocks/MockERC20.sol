// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC20} from "openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(uint256 _initialSupply, address _owner) ERC20("MockERC20", "ERC20") {
        _mint(_owner, _initialSupply);
    }
}
