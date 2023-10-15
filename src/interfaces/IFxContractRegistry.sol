// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/*//////////////////////////////////////////////////////////////////////////
                                  STRUCTS
//////////////////////////////////////////////////////////////////////////*/

/**
 * @notice Struct of system config information
 * @param lockTime Locked time duration added to mint start time for unverified creators
 * @param referrerShare Share amount distributed to accounts referring tokens
 * @param defaultMetadata Default metadata URI of all unrevealed tokens
 */
struct ConfigInfo {
    uint128 lockTime;
    uint128 referrerShare;
    string defaultMetadata;
}

/**
 * @title IFxContractRegistry
 * @author fx(hash)
 * @notice Registry for managing fxhash smart contracts
 */
interface IFxContractRegistry {
    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when contract gets registered
     * @param _contractName Name of the contract
     * @param _hashedName Hashed name of the contract
     * @param _contractAddr Address of the contract
     */
    event ContractRegistered(string indexed _contractName, bytes32 indexed _hashedName, address indexed _contractAddr);

    /**
     * @notice Event emitted when the config information is updated
     * @param _owner Address of the registry owner
     * @param _configInfo Updated config information
     */
    event ConfigUpdated(address indexed _owner, ConfigInfo _configInfo);

    /*//////////////////////////////////////////////////////////////////////////
                                  ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Error thrown when either array is empty
     */
    error InputEmpty();

    /**
     * @notice Error thrown when array lengths do not match
     */
    error LengthMismatch();

    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns the system config information (lock time, referrer share, default metadata)
     */
    function configInfo() external view returns (uint128, uint128, string memory);

    /**
     * @notice Mapping of hashed contract name to contract address
     */
    function contracts(bytes32) external view returns (address);

    /**
     * @notice Registers deployed contract addresses based on hashed value of name
     * @param _names Array of contract names
     * @param _contracts Array of contract addresses
     */
    function register(string[] calldata _names, address[] calldata _contracts) external;

    /**
     * @notice Sets the system config information
     * @param _configInfo Config information (lock time, referrer share, default metadata)
     */
    function setConfig(ConfigInfo calldata _configInfo) external;
}
