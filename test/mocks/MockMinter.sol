// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ReserveInfo} from "src/interfaces/IFxGenArt721.sol";

contract MockMinter {
    function setMintDetails(ReserveInfo calldata, bytes calldata) external {}
}
