// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Ownable} from "solady/src/auth/Ownable.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IFeeManager} from "src/interfaces/IFeeManager.sol";

contract FeeManager is IFeeManager, Ownable {
    uint256 public mintFee;

    constructor(address _owner, uint256 _mintFee) {
        _initializeOwner(_owner);
        mintFee = _mintFee;
    }

    receive() external payable {}

    function setMintFee(uint256 _mintFee) external onlyOwner {
        emit MintFeeSet(mintFee, _mintFee);
        mintFee = _mintFee;
    }

    function withdraw(address _to) external onlyOwner {
        uint256 balance = address(this).balance;
        SafeTransferLib.safeTransferETH(_to, balance);
    }

    function calculateFee(uint256 _price, uint256 _amount) external view returns (uint256) {
        return _amount * mintFee;
    }
}
