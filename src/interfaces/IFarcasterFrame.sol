// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IMinter} from "src/interfaces/IMinter.sol";
import {ReserveInfo} from "src/lib/Structs.sol";

/**
 * @title IFarcasterFrame
 * @author fx(hash)
 * @notice Minter for distributing tokens for free or at fixed prices with Farcaster Frames
 */
interface IFarcasterFrame is IMinter {
    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted a new controller wallet is set
     * @param _prevController Address of the previous controller
     * @param _newController Address of the new controller
     */
    event ControllerSet(address _prevController, address _newController);

    /**
     * @notice Event emitted when a new frame fixed price mint has been set
     * @param _token Address of the token being minted
     * @param _reserveId ID of the reserve
     * @param _price Amount of fixed price mint
     * @param _reserveInfo Reserve information for the mint
     * @param _openEdition Status of an open edition mint
     * @param _timeUnlimited Status of a mint with unlimited time
     * @param _maxAmountPerFid Maximum amount of tokens that can be minted per Farcaster ID (only for free frames)
     */
    event MintDetailsSet(
        address indexed _token,
        uint256 indexed _reserveId,
        uint256 _price,
        ReserveInfo _reserveInfo,
        bool _openEdition,
        bool _timeUnlimited,
        uint256 _maxAmountPerFid
    );

    /**
     * @notice Event emitted when a new free frame token has been minted
     * @param _token Address of the token being minted
     * @param _to Address receiving the minted tokens
     * @param _fid Farcaster ID of the receiver
     */
    event FrameMinted(address indexed _token, address indexed _to, uint256 indexed _fid);

    /**
     * @notice Event emitted when a purchase is made
     * @param _token Address of the token being purchased
     * @param _reserveId ID of the mint
     * @param _buyer Address purchasing the tokens
     * @param _amount Amount of tokens being purchased
     * @param _to Address to which the tokens are being transferred
     * @param _price Price of the purchase
     */
    event Purchase(
        address indexed _token,
        uint256 indexed _reserveId,
        address indexed _buyer,
        uint256 _amount,
        address _to,
        uint256 _price
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
     * @notice Error thrown when token address is invalid
     */
    error InvalidToken();

    /**
     * @notice Error thrown when amount being minted exceeded max amount allowed per Farcaster ID
     */
    error MaxAmountExceeded();

    /**
     * @notice Error thrown when the auction has not started
     */
    error NotStarted();

    /**
     * @notice Error thrown when amount purchased exceeds remaining allocation
     */
    error TooMany();

    /**
     * @notice Error thrown when receiver is zero address
     */
    error ZeroAddress();

    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Purchases tokens at a fixed price
     * @param _token Address of the token contract
     * @param _reserveId ID of the reserve
     * @param _amount Amount of tokens being purchased
     * @param _to Address receiving the purchased tokens
     */
    function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable;

    /**
     * @notice Address of the authorized wallet for minting free tokens
     */
    function controller() external view returns (address);

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
    function getSaleProceeds(address _token) external view returns (uint128);

    /**
     * @notice Mapping of token address to max amount of mintable tokens per Farcaster ID
     */
    function maxAmounts(address) external view returns (uint256);

    /**
     * @notice Mints token for free to given wallet
     * @param _token Address of the token contract
     * @param _reserveId ID of the reserve
     * @param _fId Farcaster user ID
     * @param _to Address receiving the free token
     */
    function mint(address _token, uint256 _reserveId, uint256 _fId, address _to) external;

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
     * @notice Sets the new controller wallet address for minting free tokens
     */
    function setController(address _controller) external;

    /**
     * @inheritdoc IMinter
     * @dev Mint Details: token price, merkle root, and signer address
     */
    function setMintDetails(ReserveInfo calldata _reserveInfo, bytes calldata _mintDetails) external;

    /**
     * @notice Mapping of Farcaster ID to mapping of token address to total minted tokens
     */
    function totalMinted(uint256, address) external view returns (uint256);

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
