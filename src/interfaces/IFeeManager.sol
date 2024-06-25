// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface IFeeManager {
    event MintFeeSet(uint96 _prevFee, uint96 _newFee);

    event OwnerSet(address _prevOwner, address _newOwner);

    error NotAuthorized();

    function setMintFee(uint96 _mintFee) external;

    function setOwner(address _owner) external;

    function calculateFee(uint256 _amount) external view returns (uint256);

    function mintFee() external view returns (uint96);

    function owner() external view returns (address);
}
