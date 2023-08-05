// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";
import {IWETH} from "contracts/interfaces/IWETH.sol";

abstract contract WETHHandler {
    using SafeTransferLib for address;

    address payable internal constant weth9 = payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    constructor() payable {
        /// Dust implementers with an amount that will be outside the internal accounting
        require(msg.value == 1, "No dust");
        IWETH(weth9).deposit{value: 1}();
    }

    function _withdrawWETH(uint256 _amount, address _to) internal {
        IWETH(weth9).transfer(_to, _amount);
    }

    function _withdrawETH(uint256 _amount, address _to) internal {
        IWETH(weth9).withdraw(_amount);
        _to.safeTransferETH(address(this).balance);
    }
}
