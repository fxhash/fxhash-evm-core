// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";

import {IFxGenArt721, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IPayableFrame} from "src/interfaces/IPayableFrame.sol";

/**
 * @title PayableFrame
 * @author fx(hash)
 * @dev See the documentation in {IPayableFrame}
 */
contract PayableFrame is IPayableFrame, Ownable, Pausable {
    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    mapping(address => uint256) public prices;
    mapping(address => ReserveInfo) public reserves;

    constructor() {}

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function mint(address _token, address _to, uint256 _amount, uint256 _fid) external payable whenNotPaused {
        if (_to == address(0)) revert ZeroAddress();
        uint256 price = prices[_token];
        if (msg.value != _amount * price) revert InvalidPayment();
        ReserveInfo memory reserveInfo = reserves[_token];
        if (reserveInfo.startTime > block.timestamp || reserveInfo.endTime < block.timestamp) {
            revert InvalidTime();
        }

        reserves[_token].allocation -= uint128(_amount);

        IFxGenArt721(_token).mint(_to, _amount, price);

        emit FrameMinted(_token, _to, _fid, _amount);
    }

    function setMintDetails(ReserveInfo calldata _reserveInfo, bytes calldata _mintDetails) external whenNotPaused {
        uint256 price = abi.decode(_mintDetails, (uint256));
        prices[msg.sender] = price;
        reserves[msg.sender] = _reserveInfo;

        emit MintDetailsSet(msg.sender, _reserveInfo, price);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
