// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

contract Accounts is Script {
    address public admin;
    address public signer;
    address public treasury;
    address public moderator;
    address public alice;
    address public bob;
    address public eve;
    address public susan;

    uint256 public constant BALANCE = 100 ether;

    function setUp() public virtual {
        createAccounts();
    }

    function _createUser(string memory _name) internal returns (address user) {
        user = address(uint160(uint256(keccak256(abi.encodePacked(_name)))));
        vm.deal(user, BALANCE);
        vm.label(user, _name);
    }

    function createAccounts() public virtual {
        admin = _createUser("admin");
        signer = _createUser("signer");
        treasury = _createUser("treasury");
        alice = _createUser("alice");
        bob = _createUser("bob");
        eve = _createUser("eve");
        susan = _createUser("susan");
    }
}
