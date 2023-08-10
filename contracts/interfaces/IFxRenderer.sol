// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {HTMLRequest} from "scripty.sol/contracts/scripty/interfaces/IScriptyBuilderV2.sol";

/**
 * @title IFxRenderer
 * @notice Renders metadata of onchain scripts for Generative Art tokens
 */
interface IFxRenderer {
    function renderMetadata(
        uint256 _tokenId,
        bytes32 _seed,
        bytes calldata _fxParams,
        HTMLRequest calldata _animationURL,
        HTMLRequest calldata _attributes
    ) external view returns (string memory);
}
