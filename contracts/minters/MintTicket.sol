// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Minted, Reserve} from "contracts/minters/base/Minted.sol";
import {IMintTicket} from "contracts/interfaces/IMintTicket2.sol";
import {IMinter} from "contracts/interfaces/IMinter.sol";

contract MintTicket is Minted, IMintTicket, IMinter {
    mapping(address => address) public mintTicketContracts;

    function setMintDetails(uint256, uint256, uint256, bytes calldata) external {}

    function mint(address _token, uint256 _id, bytes calldata _mintParams, address _to) external {
        IMintTicket(mintTicketContracts[_token]).burn(_id);
        Minted(_token).mint(1, _mintParams, _to);
    }

    function mint(uint256, address) external override {}

    function mint(uint256, bytes calldata, address) external override {}

    function burn(uint256) external {}

    function setMintDetails(Reserve calldata _reserve, bytes calldata _minterData) external {
        _registerMinter(msg.sender, _reserve, _minterData);
    }

    function feeReceiver() external pure override returns (address) {
        return address(420);
    }
}
