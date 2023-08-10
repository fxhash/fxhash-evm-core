// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";

/// @notice Library for computing the Create2 deterministic address of a clone
/// https://github.com/0xSplits/splits-contracts/blob/c7b741926ec9746182d0d1e2c4c2046102e5d337/contracts/libraries/Clones.sol#L22
library Lib0xSplits {
    /// @notice constant to scale uints into percentages (1e6 == 100%)
    uint256 public constant PERCENTAGE_SCALE = 1e6;
    /// @notice maximum distributor fee; 1e5 = 10% * PERCENTAGE_SCALE
    uint256 internal constant MAX_DISTRIBUTOR_FEE = 1e5;

    /// @notice Deployment of 0xSplitsMain on goerli and mainnet
    address internal constant SPLITS_MAIN = 0x2ed6c4B5dA6378c7897AC67Ba9e43102Feb694EE;

    /// @notice Deployment of 0xSplits Wallet on goerli and mainnet
    address internal constant SPLITS_WALLET = 0xD94c0CE4f8eEfA4Ebf44bf6665688EdEEf213B33;

    /// @notice Invalid number of accounts `accountsLength`, must have at least 2
    /// @param accountsLength Length of accounts array
    error TooFewAccounts(uint256 accountsLength);
    /// @notice Array lengths of accounts & percentAllocations don't match (`accountsLength` !=
    /// `allocationsLength`)
    /// @param accountsLength Length of accounts array
    /// @param allocationsLength Length of percentAllocations array
    error AccountsAndAllocationsMismatch(uint256 accountsLength, uint256 allocationsLength);
    /// @notice Invalid percentAllocations sum `allocationsSum` must equal `PERCENTAGE_SCALE`
    /// @param allocationsSum Sum of percentAllocations array
    error InvalidAllocationsSum(uint32 allocationsSum);
    /// @notice Invalid accounts ordering at `index`
    /// @param index Index of out-of-order account
    error AccountsOutOfOrder(uint256 index);
    /// @notice Invalid percentAllocation of zero at `index`
    /// @param index Index of zero percentAllocation
    error AllocationMustBePositive(uint256 index);
    /// @notice Invalid distributorFee `distributorFee` cannot be greater than 10% (1e5)
    /// @param distributorFee Invalid distributorFee amount
    error InvalidDistributorFee(uint32 distributorFee);

    function getImmutableSplitAddress(address[] memory accounts, uint32[] memory allocations)
        internal
        view
        returns (address)
    {
        return ISplitsMain(SPLITS_MAIN).predictImmutableSplitAddress(accounts, allocations, 0);
    }

    /**
     * @notice Reverts if the split with recipients represented by `accounts` and
     * `percentAllocations` is malformed
     *  @param accounts Ordered, unique list of addresses with ownership in the split
     *  @param percentAllocations Percent allocations associated with each address
     *  @param distributorFee Keeper fee paid by split to cover gas costs of distribution
     */
    function _validateSplit(
        address[] memory accounts,
        uint32[] memory percentAllocations,
        uint32 distributorFee
    ) internal pure {
        if (accounts.length < 2) revert TooFewAccounts(accounts.length); // Too few accounts
        if (accounts.length != percentAllocations.length) {
            revert AccountsAndAllocationsMismatch(accounts.length, percentAllocations.length);
        }
        // _getSum should overflow if any percentAllocation[i] < 0
        if (_getSum(percentAllocations) != PERCENTAGE_SCALE) {
            revert InvalidAllocationsSum(_getSum(percentAllocations));
        }
        unchecked {
            // overflow should be impossible in for-loop index
            // cache accounts length to save gas
            uint256 loopLength = accounts.length - 1;
            for (uint256 i = 0; i < loopLength; ++i) {
                // overflow should be impossible in array access math
                if (accounts[i] >= accounts[i + 1]) revert AccountsOutOfOrder(i);
                if (percentAllocations[i] == uint32(0)) revert AllocationMustBePositive(i);
            }
            // overflow should be impossible in array access math with validated equal array lengths
            if (percentAllocations[loopLength] == uint32(0)) {
                revert AllocationMustBePositive(loopLength);
            }
        }
        if (distributorFee > MAX_DISTRIBUTOR_FEE) revert InvalidDistributorFee(distributorFee);
    }

    /**
     * @notice Hashes a split
     *  @param accounts Ordered, unique list of addresses with ownership in the split
     *  @param percentAllocations Percent allocations associated with each address
     *  @param distributorFee Keeper fee paid by split to cover gas costs of distribution
     *  @return computedHash Hash of the split that is used as the salt for the split
     */
    function _hashSplit(
        address[] memory accounts,
        uint32[] memory percentAllocations,
        uint32 distributorFee
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(accounts, percentAllocations, distributorFee));
    }

    /// How I think this will work is we pass the total royalty amount ie 10%
    /// and then pass accounts and respective splits that must total 100%
    /// if accounts.length == 1 && percentAllocations[0] == 100% we just directly pass that to the
    /// royaltyInfo mapping
    /// else we compute the salt for the split and do this validation and set this address and
    /// royalty amount in the mapping
    function getSalt(
        address[] memory accounts,
        uint32[] memory percentAllocations,
        uint32 distributorFee
    ) internal pure returns (bytes32) {
        _validateSplit(accounts, percentAllocations, distributorFee);
        return _hashSplit(accounts, percentAllocations, distributorFee);
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address[] memory accounts,
        uint32[] memory percentAllocations
    ) internal pure returns (address predicted) {
        bytes32 salt = getSalt(accounts, percentAllocations, 0);
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d605d80600a3d3981f336603057343d52307f00000000000000000000000000)
            mstore(
                add(ptr, 0x13), 0x830d2d700a97af574b186c80d40429385d24241565b08a7c559ba283a964d9b1
            )
            mstore(
                add(ptr, 0x33), 0x60203da23d3df35b3d3d3d3d363d3d37363d7300000000000000000000000000
            )
            mstore(add(ptr, 0x46), shl(0x60, SPLITS_WALLET))
            mstore(
                add(ptr, 0x5a), 0x5af43d3d93803e605b57fd5bf3ff000000000000000000000000000000000000
            )
            mstore(add(ptr, 0x68), shl(0x60, SPLITS_MAIN))
            mstore(add(ptr, 0x7c), salt)
            mstore(add(ptr, 0x9c), keccak256(ptr, 0x67))
            predicted := keccak256(add(ptr, 0x67), 0x55)
        }
    }

    /**
     * @notice Sums array of uint32s
     *  @param numbers Array of uint32s to sum
     *  @return sum Sum of `numbers`.
     */
    function _getSum(uint32[] memory numbers) internal pure returns (uint32 sum) {
        // overflow should be impossible in for-loop index
        uint256 numbersLength = numbers.length;
        for (uint256 i = 0; i < numbersLength;) {
            sum += numbers[i];
            unchecked {
                // overflow should be impossible in for-loop index
                ++i;
            }
        }
    }
}
