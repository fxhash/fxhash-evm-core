// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IMinter} from "src/interfaces/IMinter.sol";
import {ReserveInfo} from "src/lib/Structs.sol";

/**
 * @title IFixedPriceParams
 * @author fx(hash)
 * @notice Minter for distributing fxParams tokens at fixed prices
 */
interface IFixedPriceParams is IMinter {
    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when a new fixed price mint has been set
     * @param _token Address of the token being minted
     * @param _reserveId ID of the reserve
     * @param _price Amount of fixed price mint
     * @param _merkleRoot The merkle root allowlisted buyers
     * @param _mintPassSigner The signing account for mint passes
     * @param _reserveInfo Reserve information for the mint
     * @param _openEdition Status of an open edition mint
     * @param _timeUnlimited Status of a mint with unlimited time
     */
    event MintDetailsSet(
        address indexed _token,
        uint256 indexed _reserveId,
        uint256 _price,
        ReserveInfo _reserveInfo,
        bytes32 _merkleRoot,
        address _mintPassSigner,
        bool _openEdition,
        bool _timeUnlimited
    );

    /**
     * @notice Event emitted when a purchase is made
     * @param _token Address of the token being purchased
     * @param _reserveId ID of the mint
     * @param _buyer Address purchasing the tokens
     * @param _amount Amount of tokens being purchased
     * @param _to Address to which the tokens are being transferred
     * @param _price Price of the purchase
     * @param _fxParams Random sequence of fixed-length bytes used as input
     */
    event Purchase(
        address indexed _token,
        uint256 indexed _reserveId,
        address indexed _buyer,
        uint256 _amount,
        address _to,
        uint256 _price,
        bytes _fxParams
    );

    /**
     * @notice Event emitted when sale proceeds are withdrawn
     * @param _token Address of the token
     * @param _creator Address of the project creator
     * @param _proceeds Amount of proceeds being withdrawn
     */
    event Withdrawn(address indexed _token, address indexed _creator, uint256 _proceeds);

    /*//////////////////////////////////////////////////////////////////////////
                                  ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Error thrown when receiver is zero address
     */
    error AddressZero();

    /**
     * @notice Error thrown when the sale has already ended
     */
    error Ended();

    /**
     * @notice Error thrown when no funds available to withdraw
     */
    error InsufficientFunds();

    /**
     * @notice Error thrown when the allocation amount is zero
     */
    error InvalidAllocation();

    /**
     * @notice Error thrown when payment does not equal price
     */
    error InvalidPayment();

    /**
     * @notice Error thrown thrown when reserve does not exist
     */
    error InvalidReserve();

    /**
     * @notice Error thrown when reserve start and end times are invalid
     */
    error InvalidTimes();

    /**
     * @notice Error thrown when token address is invalid
     */
    error InvalidToken();

    /**
     * @notice Error thrown when buying through allowlist and no allowlist exists
     */
    error NoAllowlist();

    /**
     * @notice Error thrown when calling buy when either an allowlist or signer exists
     */
    error NoPublicMint();

    /**
     * @notice Error thrown when buy with a mint pass and no signing authority exists
     */
    error NoSigningAuthority();

    /**
     * @notice Error thrown when the auction has not started
     */
    error NotStarted();

    /**
     * @notice Error thrown when setting both an allowlist and mint signer
     */
    error OnlyAuthorityOrAllowlist();

    /**
     * @notice Error thrown when amount purchased exceeds remaining allocation
     */
    error TooMany();

    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Purchases tokens at a fixed price
     * @param _token Address of the token contract
     * @param _reserveId ID of the reserve
     * @param _to Address receiving the purchased tokens
     * @param _fxParams Random sequence of fixed-length bytes used as input
     */
    function buy(address _token, uint256 _reserveId, address _to, bytes calldata _fxParams) external payable;

    /**
     * @notice Purchases tokens through an allowlist at a fixed price
     * @param _token Address of the token being purchased
     * @param _reserveId ID of the reserve
     * @param _to Address receiving the purchased tokens
     * @param _indexes Array of indices regarding purchase info inside the BitMap
     * @param _proofs Array of merkle proofs used for verifying the purchase
     * @param _fxParams Random sequence of fixed-length bytes used as input
     */
    function buyAllowlist(
        address _token,
        uint256 _reserveId,
        address _to,
        uint256[] calldata _indexes,
        bytes32[][] calldata _proofs,
        bytes calldata _fxParams
    ) external payable;

    /**
     * @notice Purchases tokens through a mint pass at a fixed price
     * @param _token Address of the token being purchased
     * @param _reserveId ID of the reserve
     * @param _to Address receiving the purchased tokens
     * @param _index Index of puchase info inside the BitMap
     * @param _signature Array of merkle proofs used for verifying the purchase
     * @param _fxParams Random sequence of fixed-length bytes used as input
     */
    function buyMintPass(
        address _token,
        uint256 _reserveId,
        address _to,
        uint256 _index,
        bytes calldata _signature,
        bytes calldata _fxParams
    ) external payable;

    /**
     * @notice Returns the earliest valid reserveId that can mint a token
     */
    function getFirstValidReserve(address _token) external view returns (uint256);

    /**
     * @notice Gets the latest timestamp update made to token reserves
     * @param _token Address of the token contract
     * @return Timestamp of latest update
     */
    function getLatestUpdate(address _token) external view returns (uint40);

    /**
     * @notice Gets the proceed amount from a token sale
     * @param _token Address of the token contract
     * @return Amount of proceeds
     */
    function getSaleProceed(address _token) external view returns (uint128);

    /**
     * @notice Mapping of token address to reserve ID to merkle roots
     */
    function merkleRoots(address, uint256) external view returns (bytes32);

    /**
     * @notice Pauses all function executions where modifier is applied
     */
    function pause() external;

    /**
     * @notice Mapping of token address to reserve ID to prices
     */
    function prices(address, uint256) external view returns (uint256);

    /**
     * @notice Mapping of token address to reserve ID to reserve information
     */
    function reserves(address, uint256) external view returns (uint64, uint64, uint128);

    /**
     * @inheritdoc IMinter
     * @dev Mint Details: token price, merkle root, and signer address
     */
    function setMintDetails(ReserveInfo calldata _reserveInfo, bytes calldata _mintDetails) external;

    /**
     * @notice Unpauses all function executions where modifier is applied
     */
    function unpause() external;

    /**
     * @notice Withdraws the sale proceeds to the sale receiver
     * @param _token Address of the token withdrawing proceeds from
     */
    function withdraw(address _token) external;
}
