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

    event MintDetailsSet(address indexed token, ReserveInfo _reserve);

    /*//////////////////////////////////////////////////////////////////////////
                                  ERRORS
    //////////////////////////////////////////////////////////////////////////*/

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
     * @notice Pauses all function executions where modifier is applied
     */
    function pause() external;

    /**
     * @inheritdoc IMinter
     */
    function setMintDetails(ReserveInfo calldata _reserveInfo, bytes calldata _mintDetails) external;

    /**
     * @notice Unpauses all function executions where modifier is applied
     */
    function unpause() external;
}
