// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IMinter} from "src/interfaces/IMinter.sol";
import {ReserveInfo} from "src/interfaces/IFxGenArt721.sol";

interface ITicketRedeemer is IMinter {
    error AlreadySet();
    error InvalidToken();
    error NotAuthorized();

    event MintDetailsSet(address indexed ticket, address indexed token);
    event Redeemed(address indexed ticket, uint256 indexed tokenId, address indexed owner, address token);

    function burn(address _ticket, uint256 _tokenId) external;
}
