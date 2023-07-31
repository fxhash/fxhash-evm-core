// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IGenTk {
    struct TokenParams {
        uint256 tokenId;
        address receiver;
        uint256 iteration;
        bytes inputBytes;
        string metadata;
    }

    function initialize(
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints,
        address _configManager,
        address _owner,
        address _issuer
    ) external;

    function mint(TokenParams calldata _params) external;
}
