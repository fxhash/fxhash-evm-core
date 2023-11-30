// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Script.sol";
import "script/utils/Constants.sol";
import "src/utils/Constants.sol";

import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";

contract Splits is Script {
    address internal primaryReceiver;
    address internal secondaryReceiver;
    address[] internal creators;
    address[] internal primaryReceivers;
    address[] internal secondaryReceivers;
    uint32[] internal primaryAllocations;
    uint32[] internal secondaryAllocations;

    /*//////////////////////////////////////////////////////////////////////////
                                    SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        creators = new address[](15);
        primaryReceivers = new address[](2);
        secondaryReceivers = new address[](2);
        primaryAllocations = new uint32[](2);
        secondaryAllocations = new uint32[](2);
        _setUpCreators();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      RUN
    //////////////////////////////////////////////////////////////////////////*/

    function run() public virtual {
        vm.startBroadcast();
        for (uint256 i; i < creators.length; ++i) {
            _setUpSplits(creators[i]);
            primaryReceiver = ISplitsMain(SPLITS_MAIN).createSplit(primaryReceivers, primaryAllocations, 0, address(0));
            secondaryReceiver = ISplitsMain(SPLITS_MAIN).createSplit(
                secondaryReceivers,
                secondaryAllocations,
                0,
                address(0)
            );
            console.log("CREATOR", creators[i]);
            console.log("PRIMARY RECEIVER", primaryReceiver);
            console.log("SECONDARY RECEIVER", secondaryReceiver);
            console.log("=============================================");
        }
        vm.stopBroadcast();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _setUpCreators() internal {
        creators[0] = 0xed2647390b6FED5eC4e07E8036101A191f3eE4AB; // riiiis
        creators[1] = 0x21713dFBB002d7a91E5bc780e065389BDF4ed9f2; // KALA
        creators[2] = 0x8571027db178A535d56335Adb0580abd2fF29274; // Ivan Dianov
        creators[3] = 0x68859f535A63C5306bF24C352ABA0c3964Ef503e; // JohnRising
        creators[4] = 0xe60Ff879355BF3Df475428f25Fe165fDa7FfbfB3; // obi.tez
        creators[5] = 0xC3C05DAae54D6d496597FAc9403F49aE5B4Fb34D; // Piter Pasma
        creators[6] = 0xEb19454f430755590871DfBba5b386B707dc6eA3; // ella
        creators[7] = 0x0723AEe4A8c0922e5B42194f3Fe1B9Ee339321B0; // Teaboswell
        creators[8] = 0x4Bf6ae441d0dCb587e85b0Dd135947C5adbbb401; // Seanelliottoc
        creators[9] = 0xF523011fC571d67beB53ee108FDEB010D1ADdBE9; // ippsketch
        creators[10] = 0x457ee5f723C7606c12a7264b52e285906F91eEA6; // Casey Reas
        creators[11] = 0x8296570621ACb325f21E5E6F4BF96Bee6Bf8555e; // OASIS
        creators[12] = 0xc6f1443C4A4e33e6861d873299F69CedBeD9d6be; // Richard Boeser
        creators[13] = 0xaed7325CC3c864c0b2D8043a176139e3eb726214; // Joey Zaza
        creators[14] = 0x5fa19ADfDE9D18eB71dA70529930B2Dd4b2ad3cC; // Nightsea
    }

    function _setUpSplits(address _creator) internal {
        if (_creator > ADMIN_SAFE_WALLET) {
            primaryReceivers[0] = ADMIN_SAFE_WALLET;
            primaryReceivers[1] = _creator;
            primaryAllocations[0] = PRIMARY_ADMIN_ALLOCATION;
            primaryAllocations[1] = PRIMARY_CREATOR_ALLOCATION;

            secondaryReceivers[0] = ADMIN_SAFE_WALLET;
            secondaryReceivers[1] = _creator;
            secondaryAllocations[0] = SECONDARY_ADMIN_ALLOCATION;
            secondaryAllocations[1] = SECONDARY_CREATOR_ALLOCATION;
        } else {
            primaryReceivers[0] = _creator;
            primaryReceivers[1] = ADMIN_SAFE_WALLET;
            primaryAllocations[0] = PRIMARY_CREATOR_ALLOCATION;
            primaryAllocations[1] = PRIMARY_ADMIN_ALLOCATION;

            secondaryReceivers[0] = _creator;
            secondaryReceivers[1] = ADMIN_SAFE_WALLET;
            secondaryAllocations[0] = SECONDARY_CREATOR_ALLOCATION;
            secondaryAllocations[1] = SECONDARY_ADMIN_ALLOCATION;
        }
    }
}
