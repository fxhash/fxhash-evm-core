// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "script/Deploy.s.sol";

contract Seed is Deploy {
    function _run() internal override {
        super._run();
        _initializeState();
        for (uint256 i; i < 20; i++) {
            _createProject();
            _mint();
        }
    }

    function _initializeState() internal {
        creator = msg.sender;
        delete mintInfo;
        _configureMinter(
            address(fixedPrice),
            uint64(block.timestamp) + RESERVE_START_TIME,
            uint64(block.timestamp) + RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE)
        );
    }

    function _mint() internal {
        IFxGenArt721(fxGenArtProxy).toggleMint();
        for (uint256 i; i < 20; i++) {
            IFxGenArt721(fxGenArtProxy).ownerMint(creator);
        }
    }
}
