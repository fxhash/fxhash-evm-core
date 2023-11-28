// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Allowlist} from "src/minters/extensions/Allowlist.sol";
import {LibBitmap} from "solady/src/utils/LibBitmap.sol";
import {LibMap} from "solady/src/utils/LibMap.sol";
import {MintPass} from "src/minters/extensions/MintPass.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IFixedPrice} from "src/interfaces/IFixedPrice.sol";
import {IToken} from "src/interfaces/IToken.sol";
import {ReserveInfo} from "src/lib/Structs.sol";

import {OPEN_EDITION_SUPPLY, TIME_UNLIMITED} from "src/utils/Constants.sol";

/**
 * @title FixedPrice
 * @author fx(hash)
 * @dev See the documentation in {IFixedPrice}
 */
contract FixedPrice is IFixedPrice, Allowlist, MintPass {
    using SafeCastLib for uint256;

    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Mapping of token address to reserve ID to Bitmap of claimed merkle tree slots
     */
    mapping(address => mapping(uint256 => LibBitmap.Bitmap)) internal claimedMerkleTreeSlots_;

    /**
     * @dev Mapping of token address to reserve ID to Bitmap of claimed mint passes
     */
    mapping(address => mapping(uint256 => LibBitmap.Bitmap)) internal claimedMintPasses_;

    /**
     * @dev Mapping of token address to timestamp of latest update made for token reserves
     */
    LibMap.Uint40Map internal latestUpdates_;

    /**
     * @dev Mapping of token address to sale proceeds
     */
    LibMap.Uint128Map internal saleProceeds_;

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

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFixedPrice
     */
    function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable {
        bytes32 merkleRoot = _getMerkleRoot(_token, _reserveId);
        address signer = signingAuthorities[_token][_reserveId];
        if (merkleRoot != bytes32(0)) revert NoPublicMint();
        if (signer != address(0)) revert AddressZero();
        _buy(_token, _reserveId, _amount, _to);
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
        bytes32 merkleRoot = _getMerkleRoot(_token, _reserveId);
        if (merkleRoot == bytes32(0)) revert NoAllowlist();
        LibBitmap.Bitmap storage claimBitmap = claimedMerkleTreeSlots_[_token][_reserveId];
        uint256 amount = _proofs.length;
        for (uint256 i; i < amount; ++i) {
            _claimSlot(_token, _reserveId, _indexes[i], _proofs[i], claimBitmap);
        }

        _buy(_token, _reserveId, amount, _to);
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
        address signer = signingAuthorities[_token][_reserveId];
        if (signer == address(0)) revert NoSigningAuthority();
        LibBitmap.Bitmap storage claimBitmap = claimedMintPasses_[_token][_reserveId];
        _claimMintPass(_token, _reserveId, _index, _signature, claimBitmap);
        _buy(_token, _reserveId, _amount, _to);
    }

    /**
     * @inheritdoc IFixedPrice
     */
    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintDetails) external {
        if (getLatestUpdate(msg.sender) != block.timestamp) {
            delete prices[msg.sender];
            delete reserves[msg.sender];
            _setLatestUpdate(msg.sender, block.timestamp);
        }

        if (_reserve.allocation == 0) revert InvalidAllocation();
        (uint256 price, bytes32 merkleRoot, address signer) = abi.decode(_mintDetails, (uint256, bytes32, address));
        if (merkleRoot != bytes32(0) && signer != address(0)) revert OnlyAuthorityOrAllowlist();

        uint256 reserveId = reserves[msg.sender].length;
        delete merkleRoots[msg.sender][reserveId];
        delete signingAuthorities[msg.sender][reserveId];

        if (merkleRoot != bytes32(0)) {
            merkleRoots[msg.sender][reserveId] = merkleRoot;
        }

        if (signer != address(0)) {
            signingAuthorities[msg.sender][reserveId] = signer;
            reserveNonce[msg.sender][reserveId]++;
        }

        prices[msg.sender].push(price);
        reserves[msg.sender].push(_reserve);

        bool openEdition = _reserve.allocation == OPEN_EDITION_SUPPLY ? true : false;
        bool timeUnlimited = _reserve.endTime == TIME_UNLIMITED ? true : false;

        emit MintDetailsSet(msg.sender, reserveId, price, _reserve, merkleRoot, signer, openEdition, timeUnlimited);
    }

    /**
     * @inheritdoc IFixedPrice
     */
    function withdraw(address _token) external {
        uint256 proceeds = getSaleProceed(_token);
        if (proceeds == 0) revert InsufficientFunds();

        address saleReceiver = IToken(_token).primaryReceiver();
        _setSaleProceeds(_token, 0);

        SafeTransferLib.safeTransferETH(saleReceiver, proceeds);

        emit Withdrawn(_token, saleReceiver, proceeds);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                READ FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFixedPrice
     */
    function getLatestUpdate(address _token) public view returns (uint40) {
        return LibMap.get(latestUpdates_, uint256(uint160(_token)));
    }

    /**
     * @inheritdoc IFixedPrice
     */
    function getSaleProceed(address _token) public view returns (uint128) {
        return LibMap.get(saleProceeds_, uint256(uint160(_token)));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Purchases arbitrary amount of tokens at auction price and mints tokens to given account
     */
    function _buy(address _token, uint256 _reserveId, uint256 _amount, address _to) internal {
        uint256 length = reserves[_token].length;
        if (length == 0) revert InvalidToken();
        if (_reserveId >= length) revert InvalidReserve();

        ReserveInfo storage reserve = reserves[_token][_reserveId];
        if (block.timestamp < reserve.startTime) revert NotStarted();
        if (block.timestamp > reserve.endTime) revert Ended();
        if (_amount > reserve.allocation) revert TooMany();
        if (_to == address(0)) revert AddressZero();

        uint256 price = _amount * prices[_token][_reserveId];
        if (msg.value != price) revert InvalidPayment();

        reserve.allocation -= _amount.safeCastTo128();
        _setSaleProceeds(_token, getSaleProceed(_token) + price);

        IToken(_token).mint(_to, _amount, price);

        emit Purchase(_token, _reserveId, msg.sender, _amount, _to, price);
    }

    /**
     * @dev Sets timestamp of the latest update to token reserves
     */
    function _setLatestUpdate(address _token, uint256 _timestamp) internal {
        LibMap.set(latestUpdates_, uint256(uint160(_token)), uint40(_timestamp));
    }

    /**
     * @dev Sets the proceed amount from the token sale
     */
    function _setSaleProceeds(address _token, uint256 _amount) internal {
        LibMap.set(saleProceeds_, uint256(uint160(_token)), uint128(_amount));
    }

    /**
     * @dev Gets the merkle root of a token reserve
     */
    function _getMerkleRoot(address _token, uint256 _reserveId) internal view override returns (bytes32) {
        return merkleRoots[_token][_reserveId];
    }
}
