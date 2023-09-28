// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ReserveInfo, IFxGenArt721} from "src/interfaces/IFxGenArt721.sol";

contract MockMinter {
    function setMintDetails(ReserveInfo calldata, bytes calldata) external {}

    function mint(address token, address to, uint256 amount) external {
        IFxGenArt721(token).mint(to, amount);
    }
}
