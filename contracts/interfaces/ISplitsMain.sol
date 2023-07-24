// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface ISplitsMain {
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

    function withdraw(
        address account,
        uint256 withdrawETH,
        address[] /*this was type(ERC20)[]*/ calldata tokens
    ) external;

    function walletImplementation() external returns (address);

    function predictImmutableSplitAddress(
        address[] calldata accounts,
        uint32[] calldata percentAllocations,
        uint32 distributorFee
    ) external view returns (address);
}
