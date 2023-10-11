// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/FixedPrice/FixedPriceTest.t.sol";

contract SetMintDetails is FixedPriceTest {
    function test_setMintDetails() public {
        fixedPrice.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(price, merkleRoot, mintPassSigner)
        );
        (startTime, endTime, supply) = fixedPrice.reserves(address(this), 0);
        assertEq(fixedPrice.prices(address(this), 0), price, "price incorrectly set");
        assertEq(RESERVE_START_TIME, startTime, "startTime incorrectly set");
        assertEq(RESERVE_END_TIME, endTime, "endTime incorrectly set");
        assertEq(MINTER_ALLOCATION, supply, "supply incorrectly set");
    }

    function test_RevertsWhen_BothSignerAndMerkleRoot() public {
        merkleRoot = bytes32(uint256(1));
        mintPassSigner = address(1);
        vm.expectRevert();
        fixedPrice.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(price, merkleRoot, mintPassSigner)
        );
    }

    function test_RevertsIf_Allocation0() public {
        vm.expectRevert(INVALID_ALLOCATION_ERROR);
        fixedPrice.setMintDetails(ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, 0), abi.encode(price));
    }

    function test_RevertsIf_Price0() public {
        vm.expectRevert(INVALID_PRICE_ERROR);
        fixedPrice.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(0, merkleRoot, mintPassSigner)
        );
    }
}
