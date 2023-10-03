// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "script/Deploy.s.sol";

contract Seed is Deploy {
    function run() public override {
        super.run();
        creator = msg.sender;
        for (uint256 i; i < 20; i++) {
            _configure();
            _mint();
        }
    }

    function _configure() internal {
        _createProject();
        _setContracts();
        IFxGenArt721(fxGenArtProxy).toggleMint();
    }

    function _mint() internal {
        for (uint256 i; i < 20; i++) {
            IFxGenArt721(fxGenArtProxy).ownerMint(creator);
        }
    }
}
