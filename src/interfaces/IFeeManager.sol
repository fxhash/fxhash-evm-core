// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface IFeeManager {
    event MintFeeSet(uint256 _prevFee, uint256 _newFee);

    error NotAuthorized();

    function setMintFee(uint256 _mintFee) external;

    function withdraw(address _to) external;

    function calculateFee(uint256 _price, uint256 _amount) external view returns (uint256);

    function mintFee() external view returns (uint256);
}
