// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibIssuer.sol";
import {WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";

interface IOnChainTokenMetadataManager {
    struct TokenAttribute {
        string key;
        string value;
    }

    function getOnChainURI(
        bytes calldata _metadata,
        bytes calldata _onChainScripts
    ) external view returns (string memory);
}
