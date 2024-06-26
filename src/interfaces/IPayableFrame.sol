// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IMinter} from "src/interfaces/IMinter.sol";
import {ReserveInfo} from "src/lib/Structs.sol";

/**
 * @title IPayableFrame
 * @author fx(hash)
 * @notice Minter for distributing tokens by fixed price through Farcaster Frames
 */
interface IPayableFrame is IMinter {
    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    event FrameMinted(
        address indexed _token,
        address indexed _to,
        uint256 indexed _fid,
        uint256 _amount,
        uint256 _price
    );

    event MintDetailsSet(address indexed _token, ReserveInfo _reserve, uint256 price);

    /*//////////////////////////////////////////////////////////////////////////
                                  ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Error thrown when payment amount is invalid
     */
    error InvalidPayment();

    /**
     * @notice Error thrown when current time is outside of reserve time
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
     * @notice Purchases new tokens to wallet address connected to farcaster ID
     */
    function buy(address _token, address _to, uint256 _amount, uint256 _fid) external payable;

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
