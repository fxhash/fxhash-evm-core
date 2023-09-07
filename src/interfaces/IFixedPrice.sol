// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ReserveInfo} from "src/interfaces/IFxGenArt721.sol";

interface IFixedPrice {
    error InvalidToken();
    error InvalidPrice();
    error InvalidPayment();
    error InvalidTimes();
    error InvalidAllocation();
    error NotStarted();
    error Ended();
    error TooMany();
    error AddressZero();

    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintDetails) external;
    function buyTokens(address _token, uint256 _mintId, uint256 _amount, address _to)
        external
        payable;
    function withdraw(address _token) external;
}
