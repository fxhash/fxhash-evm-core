// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ReserveInfo} from "src/interfaces/IFxGenArt721.sol";

/**
 * @title IFxMinter
 * @notice Interface for FxGenArt721 Tokens to interact with Minters
 */
interface IFxMinter {
    /**
     * @dev Sets the mint details for a token's reserves
     * @param _reserve The reserve information for the token
     * @param _mintDetails The mint details, abi.encoded price
     */
    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintDetails) external;
}
