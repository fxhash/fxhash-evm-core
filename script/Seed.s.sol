// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxGenArt721} from "src/interfaces/IFxGenArt721.sol";
import "script/Deploy.s.sol";

contract Seed is Deploy {
    function _run() internal override {
        super._run();
        creator = msg.sender;
        for (uint256 i; i < 20; i++) {
            _seedData();
        }
    }

    function _seedData() internal {
        _createProject();
        _setContracts();
        IFxGenArt721(fxGenArtProxy).toggleMint();
        for (uint256 i; i < 20; i++) {
            IFxGenArt721(fxGenArtProxy).ownerMint(creator);
        }
    }
}
