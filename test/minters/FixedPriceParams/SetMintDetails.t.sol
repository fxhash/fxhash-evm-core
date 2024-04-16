// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPriceParams/FixedPriceParamsTest.t.sol";

contract SetMintDetails is FixedPriceParamsTest {
    function test_SetMintDetails() public {
        fixedPriceParams.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(price, merkleRoot, signerAddr)
        );
        (startTime, endTime, supply) = fixedPriceParams.reserves(fxGenArtProxy, 0);
        assertEq(fixedPriceParams.prices(fxGenArtProxy, 0), price, "price incorrectly set");
        assertEq(RESERVE_START_TIME, startTime, "startTime incorrectly set");
        assertEq(RESERVE_END_TIME, endTime, "endTime incorrectly set");
        assertEq(MINTER_ALLOCATION, supply, "supply incorrectly set");
    }

    function test_RevertsWhen_SignerAndMerkleRootExist() public {
        merkleRoot = bytes32(uint256(1));
        signerAddr = address(1);
        vm.expectRevert();
        fixedPriceParams.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(price, merkleRoot, signerAddr)
        );
    }

    function test_RevertsWhen_InvalidAllocation() public {
        vm.expectRevert(INVALID_ALLOCATION_ERROR);
        fixedPriceParams.setMintDetails(ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, 0), abi.encode(price));
    }

    function test_RevertsWhen_DeregisteredReserve() public {
        fixedPriceParams.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(price, merkleRoot, signerAddr)
        );

        fixedPriceParams.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(0, merkleRoot, signerAddr)
        );

        vm.warp(block.timestamp + 1);

        fixedPriceParams.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(0, merkleRoot, signerAddr)
        );

        vm.expectRevert(INVALID_RESERVE_ERROR);
        fixedPriceParams.buy(address(this), 0, address(this), fxParams);

        vm.expectRevert(INVALID_RESERVE_ERROR);
        fixedPriceParams.buy(address(this), 1, address(this), fxParams);

        fixedPriceParams.buy(address(this), 2, address(this), fxParams);

        vm.expectRevert(INVALID_RESERVE_ERROR);
        fixedPriceParams.buy(address(this), 3, address(this), fxParams);
    }

    function mintParams(address _to, bytes calldata _fxParams) external {}
}
