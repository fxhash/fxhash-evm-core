// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";
import "forge-std/Script.sol";

import {MockToken} from "test/mocks/MockToken.sol";
import {IFixedPriceFrame} from "src/interfaces/IFixedPriceFrame.sol";

contract FixedPriceFrameTest is BaseTest {
    // State
    MockToken internal token;
    uint64 internal startTime;
    uint64 internal endTime;
    uint128 internal allocation;
    uint256 internal maxAmount;
    bytes internal mintDetails;
    uint160 internal supply;
    uint256 internal mintId;
    // Errors
    bytes4 internal ZERO_ADDRESS_ERROR = IFixedPriceFrame.ZeroAddress.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        maxAmount = 1;
        super.setUp();
        _initializeState();
        _configureRoyalties();
        _configureProject(MINT_ENABLED, MAX_SUPPLY);
        _configureMinter(
            address(fixedPriceFrame),
            RESERVE_START_TIME,
            RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE, maxAmount)
        );
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, address(fixedPriceFrame));
        _configureInit(NAME, SYMBOL, address(pseudoRandomizer), address(ipfsRenderer), tagIds);
        _createProject();
        TokenLib.unpause(admin, fxGenArtProxy);
    }
}
