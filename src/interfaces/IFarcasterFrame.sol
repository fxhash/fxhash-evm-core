// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IMinter} from "src/interfaces/IMinter.sol";
import {ReserveInfo} from "src/lib/Structs.sol";

/**
 * @title IFarcasterFrame
 * @author fx(hash)
 * @notice Minter for minting FxGenArt721 tokens with Farcaster Frames
 */
interface IFarcasterFrame is IMinter {
    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    event FrameMinted(address indexed _token, address indexed _to, uint256 indexed _fid);

    event MintDetailsSet(address indexed token, ReserveInfo _reserve, uint256 _maxAmount);

    /*//////////////////////////////////////////////////////////////////////////
                                  ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Error thrown when amount being minted exceeded max amount allowed
     */
    error InvalidAmount();

    /**
     * @notice Error thrown when signature is invalid
     */
    error InvalidSignature();

    /**
     * @notice Error thrown reserve time is invalid
     */
    error InvalidTime();

    /**
     * @notice Error thrown when receiver is zero address
     */
    error ZeroAddress();

    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Mints new tokens to wallet address connected to farcaster ID
     */
    function mint(address _token, address _to, uint256 _amount, uint256 _fid, bytes calldata _signature) external;

    /**
     * @notice Pauses all function executions where modifier is applied
     */
    function pause() external;

    /**
     * @inheritdoc IMinter
     */
    function setMintDetails(ReserveInfo calldata _reserveInfo, bytes calldata _mintDetails) external;

    /**
     * @notice Sets new backend wallet address for signing off on transactions
     */
    function setSigner(address _signer) external;

    /**
     * @notice Unpauses all function executions where modifier is applied
     */
    function unpause() external;
}
