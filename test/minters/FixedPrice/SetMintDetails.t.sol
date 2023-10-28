// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/FixedPrice/FixedPriceTest.t.sol";

contract SetMintDetails is FixedPriceTest {
    function test_setMintDetails() public {
        fixedPrice.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION, FLAGS),
            abi.encode(price, merkleRoot, mintPassSigner)
        );
        (startTime, endTime, supply, ) = fixedPrice.reserves(address(this), 0);
        assertEq(fixedPrice.prices(address(this), 0), price, "price incorrectly set");
        assertEq(RESERVE_START_TIME, startTime, "startTime incorrectly set");
        assertEq(RESERVE_END_TIME, endTime, "endTime incorrectly set");
        assertEq(MINTER_ALLOCATION, supply, "supply incorrectly set");
    }

    function test_RevertsWhen_SignerAndMerkleRootExist() public {
        merkleRoot = bytes32(uint256(1));
        mintPassSigner = address(1);
        vm.expectRevert();
        fixedPrice.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION, FLAGS),
            abi.encode(price, merkleRoot, mintPassSigner)
        );
    }

    function test_RevertsIf_AllocationZero() public {
        vm.expectRevert(INVALID_ALLOCATION_ERROR);
        fixedPrice.setMintDetails(ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, 0, FLAGS), abi.encode(price));
    }

    function test_RevertsIf_Price() public {
        vm.expectRevert(INVALID_PRICE_ERROR);
        fixedPrice.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION, FLAGS),
            abi.encode(MINIMUM_PRICE - 1, merkleRoot, mintPassSigner)
        );
    }
}
