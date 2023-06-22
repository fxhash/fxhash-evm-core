// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "contracts/abstract/admin/FxHashAdminVerify.sol";

abstract contract Treasury is FxHashAdminVerify {
    address treasury;

    function setTreasury(address _treasury) external onlyAdmin {
        treasury = _treasury;
    }

    function transferTreasury(uint256 _amount) external onlyAdmin {
        require(_amount <= address(this).balance, "INSUFFISCIENT_BALANCE");
        payable(treasury).transfer(_amount);
    }
}
