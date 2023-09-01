// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ReserveInfo} from "src/interfaces/IFxGenArt721.sol";

interface IMinter {
    function setMintDetails(ReserveInfo calldata reserveInfo, bytes calldata mintDetails)
        external;
}
