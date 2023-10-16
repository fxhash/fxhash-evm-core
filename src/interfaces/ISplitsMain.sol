// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface ISplitsMain {
    function getHash(address split) external view returns (bytes32);

    function distributeETH(
        address split,
        address[] calldata accounts,
        uint32[] calldata percentAllocations,
        uint32 distributorFee,
        address distributorAddress
    ) external;

    function createSplit(
        address[] calldata accounts,
        uint32[] calldata percentAllocations,
        uint32 distributorFee,
        address controller
    ) external returns (address);

    function withdraw(address account, uint256 withdrawETH, address[] calldata tokens) external;

    function walletImplementation() external returns (address);

    function predictImmutableSplitAddress(
        address[] calldata accounts,
        uint32[] calldata percentAllocations,
        uint32 distributorFee
    ) external view returns (address);
}
