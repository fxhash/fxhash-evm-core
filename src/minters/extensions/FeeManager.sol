// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IFeeManager} from "src/interfaces/IFeeManager.sol";

contract FeeManager is IFeeManager {
    uint96 public mintFee;
    address public owner;

    modifier onlyOwner() {
        if (msg.sender == owner) revert NotAuthorized();
        _;
    }

    constructor(address _owner) {
        owner = _owner;
        mintFee = 500000000000000; // 0.0005 ETH
    }

    function setMintFee(uint96 _mintFee) external onlyOwner {
        emit MintFeeSet(mintFee, _mintFee);
        mintFee = _mintFee;
    }

    function setOwner(address _owner) external onlyOwner {
        emit OwnerSet(owner, _owner);
        owner = _owner;
    }

    function calculateFee(uint256 _amount) external view returns (uint256) {
        return _amount * mintFee;
    }
}
