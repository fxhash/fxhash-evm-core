// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ReserveInfo} from "src/lib/Structs.sol";

/**
 * @title IMinter
 * @author fx(hash)
 * @notice Interface for FxGenArt721 tokens to interact with minters
 */
interface IMinter {
    /**
     * @notice Sets the mint details for token reserves
     * @param _reserveInfo Reserve information for the token
     * @param _mintDetails Details of the mint pertaining to the minter
     */
    function setMintDetails(ReserveInfo calldata _reserveInfo, bytes calldata _mintDetails) external;
}
