// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IGenTk {
    struct TokenParams {
        uint256 tokenId;
        address receiver;
        uint256 issuerId;
        uint256 iteration;
        bytes inputBytes;
        string metadata;
    }

    function mint(TokenParams calldata _params) external;
}
