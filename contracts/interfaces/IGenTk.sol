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

    function initialize(address _configManager, address _owner, address _issuer) external;

    /**
     * @notice The issuer calls this entrypoint to issue a NFT within the
     * project. This function is agnostic of any checks, which are happening at
     * the Issuer level; it simply registers a new NFT in the contract.
     * @param _params mint parameters 
     */
    function mint(TokenParams calldata _params) external;
}
