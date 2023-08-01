// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {wadExp, wadLn, wadMul, unsafeWadMul, toWadUnsafe} from "solmate/src/utils/SignedWadMath.sol";

/// implemented by minters
interface IMinter {
    function setMintDetails(
        uint256 _allocation,
        uint256 _startTime,
        uint256 _endTime,
        bytes calldata _minterData
    ) external;
}

/// implemented by GenTk

abstract contract Minted {
    function _registerMinter(
        address _minter,
        uint256 _allocation,
        uint256 _startTime,
        uint256 _endTime,
        bytes calldata _minterData
    ) internal {
        IMinter(_minter).setMintDetails(_allocation, _startTime, _endTime, _minterData);
    }

    function mint(uint256, address) external virtual;

    function mint(uint256, bytes calldata, address) external virtual;
}

contract MockGenerativeToken is Minted {
    /// harness function
    function registerMinter(
        address _minter,
        uint256 _allocation,
        uint256 _startTime,
        uint256 _endTime,
        bytes calldata _minterData
    ) external {
        _registerMinter(_minter, _allocation, _startTime, _endTime, _minterData);
    }

    function mint(uint256, address) external override {}

    function mint(uint256, bytes calldata, address) external override {}
}

contract MintPass is IMinter {
    using ECDSA for bytes32;

    address FXHASH_AUTHORITY;
    mapping(address => mapping(uint256 => uint256)) public redeemedBitMaps;

    error AlreadyClaimed();
    error InvalidSig();

    /// should integrate delegate cash

    function setMintDetails(uint256, uint256, uint256, bytes calldata) external {}

    function isClaimed(address _token, uint256 _index) public view returns (bool) {
        uint256 claimedWordIndex = _index / 256;
        uint256 claimedBitIndex = _index % 256;
        uint256 claimedWord = redeemedBitMaps[_token][claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function mint(
        address _token,
        address _redeemer,
        uint256 _index,
        bytes calldata _mintCode,
        bytes calldata sig,
        address _to
    ) external {
        if (isClaimed(_token, _index)) revert AlreadyClaimed();
        bytes32 hash = keccak256(abi.encodePacked(_token, msg.sender, _index, _mintCode));
        if (hash.toEthSignedMessageHash().recover(sig) != FXHASH_AUTHORITY) revert InvalidSig();
        _setClaimed(_token, _index);
        Minted(_token).mint(1, _mintCode, _to);
    }

    function _setClaimed(address _token, uint256 _index) private {
        uint256 claimedWordIndex = _index / 256;
        uint256 claimedBitIndex = _index % 256;
        redeemedBitMaps[_token][claimedWordIndex] =
            redeemedBitMaps[_token][claimedWordIndex] |
            (1 << claimedBitIndex);
    }
}

contract MerkleMint is IMinter {
    mapping(address => bytes32) public merkleRoots;
    mapping(address => mapping(uint256 => uint256)) public redeemedBitMaps;

    error AlreadyClaimed();
    error NotStarted();
    error Over();
    error InvalidProof();
    error InsufficientSlots();

    /// should integrate delegate cash

    function setMintDetails(uint256, uint256, uint256, bytes calldata) external {}

    function mint(
        address _token,
        uint256 _index,
        address _account,
        bytes32[] calldata proof,
        address _to
    ) external {
        bytes32 root = merkleRoots[_token];
        if (isClaimed(_token, _index)) revert AlreadyClaimed();

        // Verify the merkle proof.
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_index, _account))));
        if (!MerkleProof.verify(proof, root, leaf)) revert InvalidProof();

        _setClaimed(_token, _index);
        // Mark it claimed and override send the token.

        Minted(_token).mint(1, _to);
    }

    function isClaimed(address _token, uint256 _index) public view returns (bool) {
        uint256 claimedWordIndex = _index / 256;
        uint256 claimedBitIndex = _index % 256;
        uint256 claimedWord = redeemedBitMaps[_token][claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(address _token, uint256 _index) private {
        uint256 claimedWordIndex = _index / 256;
        uint256 claimedBitIndex = _index % 256;
        redeemedBitMaps[_token][claimedWordIndex] =
            redeemedBitMaps[_token][claimedWordIndex] |
            (1 << claimedBitIndex);
    }
}

contract FixedPriceMint is IMinter {
    mapping(address => uint256) public price;

    function setMintDetails(uint256, uint256, uint256, bytes calldata) external {}

    function mint(address _token, address _to) external {
        Minted(_token).mint(1, _to);
    }
}

contract DutchAuctionMint is IMinter {
    mapping(address => uint256) public startTimes;
    mapping(address => int256) public decayRates;
    mapping(address => int256) public initialPrices;

    /// @return The price of a token according to DA, scaled by 1e18.
    function getPrice(address _token) public view virtual returns (uint256) {
        int256 timeSinceStart = int256(block.timestamp - startTimes[_token]);
        return uint256(initialPrices[_token] - unsafeWadMul(decayRates[_token], timeSinceStart));
    }

    /*
     * Record the starting price of a token scaled by 1e18.
     * That will be sold along a DA at a fixed linear decay rate starting at some start time
     */
    function setMintDetails(uint256, uint256, uint256, bytes calldata) external {}

    function mint(address _token, address _to) external {
        uint256 price = getPrice(_token);
        Minted(_token).mint(1, _to);
    }
}

/// Should refactor the merkle mint first into abstract and inherit
contract DutchAuctionMerkleMint is IMinter {
    mapping(address => uint256) public startTimes;
    mapping(address => int256) public decayRates;
    mapping(address => int256) public initialPrices;

    function getPrice(address _token) public view virtual returns (uint256) {
        int256 timeSinceStart = int256(block.timestamp - startTimes[_token]);
        return uint256(initialPrices[_token] - unsafeWadMul(decayRates[_token], timeSinceStart));
    }

    /*
     * Record the starting price of a token scaled by 1e18.
     * That will be sold along a DA at a fixed linear decay rate starting at some start time
     */
    function setMintDetails(uint256, uint256, uint256, bytes calldata) external {}

    function mint(address _token, address _to) external {
        uint256 price = getPrice(_token);
        Minted(_token).mint(1, _to);
    }
}
