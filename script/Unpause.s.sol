// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script} from "forge-std/Script.sol";

interface Unpause {
    function unpause() external;

    function paused() external view returns (bool);
}

contract UnpauseScript is Script {
    address[] internal tokens = [
        0x04129D504Ef301Ef83D0EFb65cEDC38f0385B65E,
        0x0bb104C8A3ba07D1B9dAE6C2eAceD7f279314b9e,
        0x10a9E76A8EC7A41446E602B762da010f495543fE,
        0x159BFA3412F59313f12f873fcd40a8346a2058ff,
        0x1d4a0af64B17029B0a3742fE9B3349DD34D4c113,
        0x6Bb7C445645A33F2ff860Ed48910c54D040eE443,
        0x77ed176254e584E07D3223c5372f53a2647798E4,
        0x9600157eDd144D1911cf7d063c0791Df49a0D3a7,
        0x986aCCA3599EF2e4C59393fc44eea2D3e6cEE49b,
        0xBb47F0ED4A7E3BffcA75660dFa3B053FB7FcE78E,
        0xc2F273071404359Af72076e6178C54C53791F0Da,
        0xcA78beFf615a86656296a6DdA1Aa18c71dBE2f5d,
        0xE4e52d3841c9556F6c7CE38ebD712A90fa3E4634,
        0xEBAD05a55ddAb63ec2b8Fe545036748f7fde2A0c,
        0xf26E920ae7356Ca4c06B8CF3d16075C3eC9D2fC9,
        0xf3bf67c5BA9D10723eB9a966276Ad592296Cc8B0,
        0xf4D3dD492Bc90e515EBEa96b660c97C499704BB7,
        0xfCb4c7aacf340A354602FfAB6f996c6b930262b7
    ];

    function run() external {
        vm.startBroadcast();
        for (uint256 i; i < tokens.length; i++) {
            Unpause(tokens[i]).unpause();
        }
        vm.stopBroadcast();

        for (uint256 i; i < tokens.length; i++) {
            require(!Unpause(tokens[i]).paused());
        }
    }
}
