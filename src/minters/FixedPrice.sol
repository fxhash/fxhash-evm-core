// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Allowlist} from "src/minters/extensions/Allowlist.sol";
import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MintPass} from "src/minters/extensions/MintPass.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IFixedPrice} from "src/interfaces/IFixedPrice.sol";
import {IFxGenArt721, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IToken} from "src/interfaces/IToken.sol";
import {BitFlagsLib} from "src/lib/BitFlagsLib.sol";

import {MINIMUM_PRICE, OPEN_EDITION_SUPPLY, TIME_UNLIMITED} from "src/utils/Constants.sol";

/**
 * @title FixedPrice
 * @author fx(hash)
 * @dev See the documentation in {IFixedPrice}
 */
contract FixedPrice is IFixedPrice, Allowlist, MintPass {
    using SafeCastLib for uint256;
    using BitFlagsLib for uint16;

    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Mapping of token address to reserve ID to BitMap of claimed merkle tree slots
     */
    mapping(address => mapping(uint256 => BitMaps.BitMap)) internal _claimedMerkleTreeSlots;

    /**
     * @dev Mapping of token address to reserve ID to BitMap of claimed mint passes
     */
    mapping(address => mapping(uint256 => BitMaps.BitMap)) internal _claimedMintPasses;

    /**
     * @inheritdoc IFixedPrice
     */
    mapping(address => uint256) public latestUpdates;

    /**
     * @inheritdoc IFixedPrice
     */
    mapping(address => mapping(uint256 => bytes32)) public merkleRoots;

    /**
     * @inheritdoc IFixedPrice
     */
    mapping(address => uint256[]) public prices;

    /**
     * @inheritdoc IFixedPrice
     */
    mapping(address => ReserveInfo[]) public reserves;

    /**
     * @inheritdoc IFixedPrice
     */
    mapping(address => uint256) public saleProceeds;

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFixedPrice
     */
    function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable {
        ReserveInfo storage reserve = _getReserveInfo(_token, _reserveId);
        uint16 flags = reserve.flags;
        if (flags.isAllowlisted() || flags.isMintWithPass()) revert NoPublicMint();
        _buy(reserve, _token, _reserveId, _amount, _to);
    }

    /**
     * @inheritdoc IFixedPrice
     */
    function buyAllowlist(
        address _token,
        uint256 _reserveId,
        address _to,
        uint256[] calldata _indexes,
        bytes32[][] calldata _proofs
    ) external payable {
        ReserveInfo storage reserve = _getReserveInfo(_token, _reserveId);
        if (!reserve.flags.isAllowlisted()) revert NoAllowlist();
        BitMaps.BitMap storage claimBitmap = _claimedMerkleTreeSlots[_token][_reserveId];
        for (uint256 i; i < _proofs.length; i++) {
            _claimSlot(_token, _reserveId, _indexes[i], _proofs[i], claimBitmap);
        }
        uint256 amount = _proofs.length;
        _buy(reserve, _token, _reserveId, amount, _to);
    }

    /**
     * @inheritdoc IFixedPrice
     */
    function buyMintPass(
        address _token,
        uint256 _reserveId,
        uint256 _amount,
        address _to,
        uint256 _index,
        bytes calldata _signature
    ) external payable {
        ReserveInfo storage reserve = _getReserveInfo(_token, _reserveId);
        if (!reserve.flags.isMintWithPass()) revert NoSigningAuthority();
        BitMaps.BitMap storage claimBitmap = _claimedMintPasses[_token][_reserveId];
        _claimMintPass(_token, _reserveId, _index, _signature, claimBitmap);
        _buy(reserve, _token, _reserveId, _amount, _to);
    }

    /**
     * @inheritdoc IFixedPrice
     */
    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintDetails) external {
        if (latestUpdates[msg.sender] != block.timestamp) {
            delete prices[msg.sender];
            delete reserves[msg.sender];
            latestUpdates[msg.sender] = block.timestamp;
        }

        if (_reserve.allocation == 0) revert InvalidAllocation();
        uint256 reserveId = reserves[msg.sender].length;
        _saveMintDetails(reserveId, _reserve.flags, _mintDetails);
        reserves[msg.sender].push(_reserve);
    }

    /**
     * @inheritdoc IFixedPrice
     */
    function withdraw(address _token) external {
        uint256 proceeds = saleProceeds[_token];
        if (proceeds == 0) revert InsufficientFunds();

        (address saleReceiver, ) = IFxGenArt721(_token).issuerInfo();
        delete saleProceeds[_token];

        SafeTransferLib.safeTransferETH(saleReceiver, proceeds);

        emit Withdrawn(_token, saleReceiver, proceeds);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Purchases arbitrary amount of tokens at auction price and mints tokens to given account
     */
    function _buy(
        ReserveInfo storage _reserve,
        address _token,
        uint256 _reserveId,
        uint256 _amount,
        address _to
    ) internal {
        _validatePurchase(_amount, _reserve);
        if (_to == address(0)) revert AddressZero();

        uint256 price = _amount * prices[_token][_reserveId];
        if (msg.value != price) revert InvalidPayment();

        _reserve.allocation -= _amount.safeCastTo112();
        saleProceeds[_token] += price;

        IToken(_token).mint(_to, _amount, price);

        emit Purchase(_token, _reserveId, msg.sender, _amount, _to, price);
    }

    function _saveMintDetails(uint256 reserveId, uint16 _flags, bytes memory _mintDetails) internal {
        uint256 price;
        if (_flags.isAllowlisted()) {
            bytes32 merkleRoot;
            (price, merkleRoot) = abi.decode(_mintDetails, (uint256, bytes32));
            merkleRoots[msg.sender][reserveId] = merkleRoot;
        } else if (_flags.isMintWithPass()) {
            address signer;
            (price, signer) = abi.decode(_mintDetails, (uint256, address));
            signingAuthorities[msg.sender][reserveId] = signer;
        } else {
            price = abi.decode(_mintDetails, (uint256));
        }
        if (price < MINIMUM_PRICE) revert InvalidPrice();
        prices[msg.sender].push(price);
    }

    /**
     * @dev Gets the merkle root of a token reserve
     */
    function _getMerkleRoot(address _token, uint256 _reserveId) internal view override returns (bytes32) {
        return merkleRoots[_token][_reserveId];
    }

    function _getReserveInfo(address _token, uint256 _reserveId) internal view returns (ReserveInfo storage) {
        uint256 length = reserves[_token].length;
        if (length == 0) revert InvalidToken();
        if (_reserveId >= length) revert InvalidReserve();
        return reserves[_token][_reserveId];
    }

    function _validatePurchase(uint256 _amount, ReserveInfo storage _reserve) internal view {
        if (block.timestamp < _reserve.startTime) revert NotStarted();
        if (block.timestamp > _reserve.endTime) revert Ended();
        if (_amount > _reserve.allocation) revert TooMany();
        if (_amount == 0) revert InvalidAmount();
    }
}
