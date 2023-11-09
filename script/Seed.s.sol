// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract Seed is BaseTest {
    function run() public override {
        creator = msg.sender;
        _configureSplits();
        _createSplit();
        _initializeProject();
        for (uint256 i; i < 20; ++i) {
            _initializeRedeemer();
            _createProject();
            _initializeMinter();
            _createTicket();
            _mint();
        }
    }

    function _initializeProject() internal {
        _configureRoyalties();
        _configureAllowlist(merkleRoot, mintPassSigner);
        _configureProject(ONCHAIN, MINT_ENABLED, MAX_SUPPLY);
        _configureInit(NAME, SYMBOL, primaryReceiver, address(pseudoRandomizer), address(scriptyRenderer), tagIds);
    }

    function _initializeMinter() internal {
        delete mintInfo;
        _configureMinter(
            address(ticketRedeemer),
            uint64(block.timestamp) + RESERVE_START_TIME,
            uint64(block.timestamp) + RESERVE_END_TIME,
            REDEEMER_ALLOCATION,
            abi.encode(_computeTicketAddr(admin))
        );
        vm.prank(admin);
        fxRoleRegistry.grantRole(MINTER_ROLE, address(ticketRedeemer));
    }

    function _initializeRedeemer() internal {
        delete mintInfo;
        _configureMinter(
            address(fixedPrice),
            uint64(block.timestamp) + RESERVE_START_TIME,
            uint64(block.timestamp) + RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE, merkleRoot, mintPassSigner)
        );
        vm.prank(admin);
        fxRoleRegistry.grantRole(MINTER_ROLE, address(fixedPrice));
    }

    function _mint() internal {
        vm.prank(creator);
        IFxGenArt721(fxGenArtProxy).toggleMint();
        for (uint256 i; i < 20; ) {
            vm.prank(creator);
            IFxGenArt721(fxGenArtProxy).ownerMint(creator);
            unchecked {
                ++i;
            }
        }
    }
}
