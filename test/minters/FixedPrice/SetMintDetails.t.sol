// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPrice/FixedPriceTest.t.sol";

contract SetMintDetails is FixedPriceTest {
    function test_SetMintDetails() public {
        fixedPrice.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(price, merkleRoot, signerAddr)
        );
        (startTime, endTime, supply) = fixedPrice.reserves(address(this), 0);
        assertEq(fixedPrice.prices(address(this), 0), price, "price incorrectly set");
        assertEq(RESERVE_START_TIME, startTime, "startTime incorrectly set");
        assertEq(RESERVE_END_TIME, endTime, "endTime incorrectly set");
        assertEq(MINTER_ALLOCATION, supply, "supply incorrectly set");
    }

    function test_RevertsWhen_SignerAndMerkleRootExist() public {
        merkleRoot = bytes32(uint256(1));
        signerAddr = address(1);
        vm.expectRevert();
        fixedPrice.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(price, merkleRoot, signerAddr)
        );
    }

    function test_RevertsWhen_InvalidAllocation() public {
        vm.expectRevert(INVALID_ALLOCATION_ERROR);
        fixedPrice.setMintDetails(ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, 0), abi.encode(price));
    }

    function test_RevertsWhen_DeregisteredReserve() public {
        fixedPrice.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(price, merkleRoot, signerAddr)
        );

        fixedPrice.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(0, merkleRoot, signerAddr)
        );

        vm.warp(block.timestamp + 1);

        fixedPrice.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(0, merkleRoot, signerAddr)
        );

        vm.expectRevert(INVALID_RESERVE_ERROR);
        fixedPrice.buy(address(this), 1, 1, address(this));

        vm.expectRevert(INVALID_RESERVE_ERROR);
        fixedPrice.buy(address(this), 0, 1, address(this));

        fixedPrice.buy(address(this), 2, 1, address(this));

        vm.expectRevert(INVALID_RESERVE_ERROR);
        fixedPrice.buy(address(this), 3, 1, address(this));
    }

    function mint(address _to, uint256 _amount, uint256 _payment) external {}
}
