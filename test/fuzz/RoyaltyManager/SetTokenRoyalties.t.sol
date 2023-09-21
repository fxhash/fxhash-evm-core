// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/RoyaltyManager/RoyaltyManagerTest.sol";

contract SetTokenRoyaltiesTest is RoyaltyManagerTest {
    function testFuzz_SetTokenRoyalties(
        uint256 tokenId,
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints
    ) public {
        // Assume that the length of receivers and basisPoints are equal
        uint256 length =
            _receivers.length > _basisPoints.length ? _basisPoints.length : _receivers.length;
        vm.assume(length != 0);
        uint256 total;
        for (uint256 i; i < length; i++) {
            if (_basisPoints[i] > MAX_ROYALTY_BPS) continue;
            total += _basisPoints[i];

            royaltyReceivers.push(_receivers[i]);
            basisPoints.push(_basisPoints[i]);
        }

        vm.assume(FEE_DENOMINATOR > total);

        // Assume that the token exists
        MockRoyaltyManager(address(royaltyManager)).setTokenExists(tokenId, true);

        // Call the function with fuzzed inputs
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);

        // Retrieve the royalties for the token
        (address payable[] memory allReceivers, uint256[] memory allBasisPoints) =
            royaltyManager.getRoyalties(tokenId);

        // Check that the royalties match the inputs
        for (uint256 i = 0; i < royaltyReceivers.length; i++) {
            assertEq(allReceivers[i], royaltyReceivers[i]);
            assertEq(allBasisPoints[i], basisPoints[i]);
        }
    }

    function testFuzz_RevertsWhen_TokenDoesntExist(
        uint256 tokenId,
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints
    ) public {
        // Assume that the length of receivers and basisPoints are equal
        uint256 length =
            _receivers.length > _basisPoints.length ? _basisPoints.length : _receivers.length;
        vm.assume(length != 0);
        for (uint256 i; i < length; i++) {
            royaltyReceivers.push(_receivers[i]);
            basisPoints.push(_basisPoints[i]);
        }

        // Assume that the token does not exist
        MockRoyaltyManager(address(royaltyManager)).setTokenExists(tokenId, false);

        // Expect a revert
        vm.expectRevert(abi.encodeWithSelector(NON_EXISTENT_TOKEN_ERROR));

        // Call the function with fuzzed inputs
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function testFuzz_RevertsWhen_SingleGt25(
        uint256 tokenId,
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints
    ) public {
        // Assume that the length of receivers and basisPoints are equal

        uint256 length =
            _receivers.length > _basisPoints.length ? _basisPoints.length : _receivers.length;
        vm.assume(length != 0);
        for (uint256 i; i < length; i++) {
            royaltyReceivers.push(_receivers[i]);
            basisPoints.push(_basisPoints[i]);
        }

        // Assume that the token exists
        MockRoyaltyManager(address(royaltyManager)).setTokenExists(tokenId, true);

        // Assume that at least one basis point is greater than MAX_ROYALTY_BPS
        bool overMax = false;
        uint256 total;
        for (uint256 i = 0; i < basisPoints.length; i++) {
            total += basisPoints[i];
            if (basisPoints[i] > MAX_ROYALTY_BPS) {
                overMax = true;
                break;
            }
        }
        vm.assume(overMax && total < FEE_DENOMINATOR);

        // Expect a revert
        vm.expectRevert(abi.encodeWithSelector(OVER_MAX_BASIS_POINTS_ALLOWED_ERROR));

        // Call the function with fuzzed inputs
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function testFuzz_RevertsWhen_TokenAndBaseGreaterThan100(
        uint256 tokenId,
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints
    ) public {
        // Assume that the length of receivers and basisPoints are equal
        uint256 length =
            _receivers.length > _basisPoints.length ? _basisPoints.length : _receivers.length;
        vm.assume(length != 0);
        uint256 total;
        for (uint256 i; i < length; i++) {
            if (_basisPoints[i] > MAX_ROYALTY_BPS) continue;
            total += _basisPoints[i];

            royaltyReceivers.push(_receivers[i]);
            basisPoints.push(_basisPoints[i]);
        }

        // Assume that the token exists
        MockRoyaltyManager(address(royaltyManager)).setTokenExists(tokenId, true);

        vm.assume(total > FEE_DENOMINATOR);

        // Expect a revert
        vm.expectRevert(abi.encodeWithSelector(INVALID_ROYALTY_CONFIG_ERROR));

        // Call the function with fuzzed inputs
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function testFuzz_RevertsWhen_LengthMismatch(
        uint256 tokenId,
        address payable[] calldata receivers,
        uint96[] calldata basisPoints
    ) public {
        // Assume that the length of receivers and basisPoints are not equal
        vm.assume(receivers.length != basisPoints.length);

        // Assume that the token exists
        MockRoyaltyManager(address(royaltyManager)).setTokenExists(tokenId, true);

        // Expect a revert
        vm.expectRevert(abi.encodeWithSelector(LENGTH_MISMATCH_ERROR));

        // Call the function with fuzzed inputs
        royaltyManager.setTokenRoyalties(tokenId, receivers, basisPoints);
    }
}
