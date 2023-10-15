// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Allowlist} from "src/minters/extensions/Allowlist.sol";
import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MintPass} from "src/minters/extensions/MintPass.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IFixedPrice} from "src/interfaces/IFixedPrice.sol";
import {IFxGenArt721, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IMinter} from "src/interfaces/IMinter.sol";
import {OPEN_EDITION_SUPPLY, TIME_UNLIMITED} from "src/utils/Constants.sol";

/**
 * @title FixedPrice
 * @author fxhash
 * @notice See the documentation in {IFixedPrice}
 */
contract FixedPrice is IFixedPrice, Allowlist, MintPass {
    using SafeCastLib for uint256;

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

    /**
     * @inheritdoc IFixedPrice
     */
    mapping(address => mapping(uint256 => address)) public signingAuthorities;

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IMinter
     */
    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintDetails) external {
        if (latestUpdates[msg.sender] != block.timestamp) {
            delete prices[msg.sender];
            delete reserves[msg.sender];
            latestUpdates[msg.sender] = block.timestamp;
        }

        if (_reserve.allocation == 0) revert InvalidAllocation();
        (uint256 price, bytes32 merkleRoot, address signer) = abi.decode(_mintDetails, (uint256, bytes32, address));

        if (price == 0) revert InvalidPrice();
        if (merkleRoot != bytes32(0) && signer != address(0)) revert OnlyAuthorityOrAllowlist();
        uint256 reserveId = reserves[msg.sender].length;
        delete merkleRoots[msg.sender][reserveId];
        delete signingAuthorities[msg.sender][reserveId];
        if (merkleRoot != bytes32(0)) {
            merkleRoots[msg.sender][reserveId] = merkleRoot;
        }
        if (signer != address(0)) {
            signingAuthorities[msg.sender][reserveId] = signer;
        }
        prices[msg.sender].push(price);
        reserves[msg.sender].push(_reserve);

        bool openEdition = _reserve.allocation == OPEN_EDITION_SUPPLY ? true : false;
        bool timeUnlimited = _reserve.endTime == TIME_UNLIMITED ? true : false;
        emit MintDetailsSet(msg.sender, reserveId, price, _reserve, openEdition, timeUnlimited);
    }

    /**
     * @inheritdoc IFixedPrice
     */
    function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable {
        bytes32 merkleRoot = _getMerkleRoot(_token, _reserveId);
        address signer = signingAuthorities[_token][_reserveId];
        if ((merkleRoot != bytes32(0) || signer != address(0))) revert NoPublicMint();
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
        BitMaps.BitMap storage claimBitmap = _claimedMerkleTreeSlots[_token][_reserveId];
        for (uint256 i; i < _proofs.length; i++) {
            _claimSlot(_token, _reserveId, _indexes[i], _proofs[i], claimBitmap);
        }
        uint256 amount = _proofs.length;
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
        BitMaps.BitMap storage claimBitmap = _claimedMintPasses[_token][_reserveId];
        _claimMintPass(_token, _reserveId, _index, _signature, claimBitmap);
        _buy(_token, _reserveId, _amount, _to);
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
        saleProceeds[_token] += price;

        IFxGenArt721(_token).mintRandom(_to, _amount);

        emit Purchase(_token, _reserveId, msg.sender, _amount, _to, price);
    }

    /**
     * @dev Gets the merkle root of a token reserve
     */
    function _getMerkleRoot(address _token, uint256 _reserveId) internal view override returns (bytes32) {
        return merkleRoots[_token][_reserveId];
    }

    /**
     * @dev Checks if signer has signing authority
     */
    function _isSigningAuthority(
        address _signer,
        address _token,
        uint256 _reserveId
    ) internal view override returns (bool) {
        return _signer == signingAuthorities[_token][_reserveId];
    }
}
