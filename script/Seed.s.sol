// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxGenArt721} from "src/interfaces/IFxGenArt721.sol";
import "script/Deploy.s.sol";

contract Seed is Deploy {
    function _run() internal override {
        super._run();
        for (uint256 i; i < 20; i++) {
            _createProject();
        }
    }

    function _createProject() internal override {
        fxGenArtProxy = fxIssuerFactory.createProject(
            msg.sender,
            primaryReceiver,
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            basisPoints
        );

        IFxGenArt721(fxGenArtProxy).toggleMint();
        _setContracts();
        for (uint256 i; i < 20; i++) {
            IFxGenArt721(fxGenArtProxy).ownerMint(msg.sender);
        }
    }
}
