// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/abstract/admin/AuthorizedCaller.sol";

abstract contract Treasury is AuthorizedCaller {
    address treasury;

    function setTreasury(address _treasury) external onlyAdmin {
        treasury = _treasury;
    }

    function transferTreasury(uint256 _amount) external onlyAdmin {
        require(_amount <= address(this).balance, "INSUFFISCIENT_BALANCE");
        payable(treasury).transfer(_amount);
    }
}
