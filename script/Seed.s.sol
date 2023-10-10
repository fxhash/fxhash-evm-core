// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "script/Deploy.s.sol";

contract Seed is Deploy {
    function _run() internal override {
        super._run();
        for (uint256 i; i < 20; i++) {
            _initializeState();
            _createProject();
            _createTicket();
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
        _configureMinter(
            address(ticketRedeemer),
            uint64(block.timestamp) + RESERVE_START_TIME,
            uint64(block.timestamp) + RESERVE_END_TIME,
            REDEEMER_ALLOCATION,
            abi.encode(_computeTicketAddr(msg.sender))
        );
    }

    function _mint() internal {
        IFxGenArt721(fxGenArtProxy).toggleMint();
        for (uint256 i; i < 20; i++) {
            IFxGenArt721(fxGenArtProxy).ownerMintRandom(creator);
        }
    }
}
