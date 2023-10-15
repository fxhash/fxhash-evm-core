// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ReserveInfo} from "src/interfaces/IFxGenArt721.sol";

/**
 * @title IMinter
 * @author fxhash
 * @notice Interface for FxGenArt721 Tokens to interact with minters
 */
interface IMinter {
    /**
     * @notice Sets the mint details for token reserves
     * @param _reserveInfo Reserve information for the token
     * @param _mintDetails Mint details pertaining to the minter
     */
    function setMintDetails(ReserveInfo calldata _reserveInfo, bytes calldata _mintDetails) external;
}
