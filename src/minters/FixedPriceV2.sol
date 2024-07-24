// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Allowlist} from "src/minters/extensions/Allowlist.sol";
import {LibBitmap} from "solady/src/utils/LibBitmap.sol";
import {LibMap} from "solady/src/utils/LibMap.sol";
import {MintPass} from "src/minters/extensions/MintPass.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IFeeManager} from "src/interfaces/IFeeManager.sol";
import {IFixedPriceV2} from "src/interfaces/IFixedPriceV2.sol";
import {IToken} from "src/interfaces/IToken.sol";
import {ReserveInfo} from "src/lib/Structs.sol";

import {OPEN_EDITION_SUPPLY, TIME_UNLIMITED} from "src/utils/Constants.sol";

/**
 * @title FixedPriceV2
 * @author fx(hash)
 * @dev See the documentation in {IFixedPriceV2}
 */
contract FixedPriceV2 is IFixedPriceV2, Allowlist, MintPass, Ownable, Pausable {
    using SafeCastLib for uint256;

    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Mapping of token address to reserve ID to Bitmap of claimed merkle tree slots
     */
    mapping(address => mapping(uint256 => LibBitmap.Bitmap)) internal claimedMerkleTreeSlots;

    /**
     * @dev Mapping of token address to reserve ID to Bitmap of claimed mint passes
     */
    mapping(address => mapping(uint256 => LibBitmap.Bitmap)) internal claimedMintPasses;

    /**
     * @dev Mapping of token address to timestamp of latest update made for token reserves
     */
    LibMap.Uint40Map internal latestUpdates;

    /**
     * @dev Mapping of token to the last valid reserveId that can mint on behalf of the token
     */
    LibMap.Uint40Map internal firstValidReserve;

    /**
     * @dev Mapping of token address to sale proceeds
     */
    LibMap.Uint128Map internal saleProceeds;

    /**
     * @inheritdoc IFixedPriceV2
     */
    address public feeManager;

    /**
     * @inheritdoc IFixedPriceV2
     */
    address public frameController;

    /**
     * @inheritdoc IFixedPriceV2
     */
    mapping(address => mapping(uint256 => bytes32)) public merkleRoots;

    /**
     * @inheritdoc IFixedPriceV2
     */
    mapping(address => uint256[]) public prices;

    /**
     * @inheritdoc IFixedPriceV2
     */
    mapping(address => ReserveInfo[]) public reserves;

    /**
     * @inheritdoc IFixedPriceV2
     */
    mapping(address => uint256) public maxAmounts;

    /**
     * @inheritdoc IFixedPriceV2
     */
    mapping(uint256 => mapping(address => uint256)) public totalMinted;

    /*//////////////////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(address _owner, address _frameController, address _feeManager) {
        _initializeOwner(_owner);
        frameController = _frameController;
        feeManager = _feeManager;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFixedPriceV2
     */
    function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable whenNotPaused {
        bytes32 merkleRoot = _getMerkleRoot(_token, _reserveId);
        address signer = signingAuthorities[_token][_reserveId];
        if (merkleRoot != bytes32(0)) revert NoPublicMint();
        if (signer != address(0)) revert AddressZero();
        _buy(_token, _reserveId, _amount, _to);
    }

    /**
     * @inheritdoc IFixedPriceV2
     */
    function buyAllowlist(
        address _token,
        uint256 _reserveId,
        address _to,
        uint256[] calldata _indexes,
        bytes32[][] calldata _proofs
    ) external payable whenNotPaused {
        bytes32 merkleRoot = _getMerkleRoot(_token, _reserveId);
        if (merkleRoot == bytes32(0)) revert NoAllowlist();
        LibBitmap.Bitmap storage claimBitmap = claimedMerkleTreeSlots[_token][_reserveId];
        uint256 amount = _proofs.length;
        for (uint256 i; i < amount; ++i) {
            _claimSlot(_token, _reserveId, _indexes[i], _to, _proofs[i], claimBitmap);
        }

        _buy(_token, _reserveId, amount, _to);
    }

    /**
     * @inheritdoc IFixedPriceV2
     */
    function buyMintPass(
        address _token,
        uint256 _reserveId,
        uint256 _amount,
        address _to,
        uint256 _index,
        bytes calldata _signature
    ) external payable whenNotPaused {
        address signer = signingAuthorities[_token][_reserveId];
        if (signer == address(0)) revert NoSigningAuthority();
        LibBitmap.Bitmap storage claimBitmap = claimedMintPasses[_token][_reserveId];
        _claimMintPass(_token, _reserveId, _index, _to, _signature, claimBitmap);
        _buy(_token, _reserveId, _amount, _to);
    }

    /**
     * @inheritdoc IFixedPriceV2
     */
    function mint(address _token, uint256 _reserveId, uint256 _fId, address _to) external whenNotPaused {
        uint256 length = reserves[_token].length;
        if (length == 0) revert InvalidToken();
        uint256 validReserve = getFirstValidReserve(_token);
        if (_reserveId >= length || _reserveId < validReserve) revert InvalidReserve();
        if (msg.sender != frameController) revert Unauthorized();
        if (totalMinted[_fId][_token] == maxAmounts[_token]) revert MaxAmountExceeded();

        totalMinted[_fId][_token]++;

        ReserveInfo storage reserve = reserves[_token][_reserveId];
        if (block.timestamp < reserve.startTime) revert NotStarted();
        if (block.timestamp > reserve.endTime) revert Ended();
        if (reserve.allocation == 0) revert TooMany();
        if (_to == address(0)) revert AddressZero();

        reserve.allocation--;

        IToken(_token).mint(_to, 1, 0);

        emit FrameMinted(_token, _to, _fId);
    }

    /**
     * @inheritdoc IFixedPriceV2
     */
    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintDetails) external whenNotPaused {
        uint256 nextReserve = reserves[msg.sender].length;
        if (getLatestUpdate(msg.sender) != block.timestamp) {
            _setLatestUpdate(msg.sender, block.timestamp);
            _setFirstValidReserve(msg.sender, nextReserve);
        }

        if (_reserve.allocation == 0) revert InvalidAllocation();
        (uint256 price, bytes32 merkleRoot, address signer, uint256 maxAmount) = abi.decode(
            _mintDetails,
            (uint256, bytes32, address, uint256)
        );
        if (merkleRoot != bytes32(0)) {
            if (signer != address(0)) revert OnlyAuthorityOrAllowlist();
            merkleRoots[msg.sender][nextReserve] = merkleRoot;
        } else if (signer != address(0)) {
            signingAuthorities[msg.sender][nextReserve] = signer;
            reserveNonce[msg.sender][nextReserve]++;
        }

        prices[msg.sender].push(price);
        maxAmounts[msg.sender] = maxAmount;
        reserves[msg.sender].push(_reserve);

        bool openEdition = _reserve.allocation == OPEN_EDITION_SUPPLY ? true : false;
        bool timeUnlimited = _reserve.endTime == TIME_UNLIMITED ? true : false;

        emit MintDetailsSet(
            msg.sender,
            nextReserve,
            price,
            _reserve,
            merkleRoot,
            signer,
            openEdition,
            timeUnlimited,
            maxAmount
        );
    }

    /**
     * @inheritdoc IFixedPriceV2
     */
    function withdraw(address _token) external whenNotPaused {
        uint256 proceeds = getSaleProceed(_token);
        if (proceeds == 0) revert InsufficientFunds();

        address saleReceiver = IToken(_token).primaryReceiver();
        _setSaleProceeds(_token, 0);

        SafeTransferLib.safeTransferETH(saleReceiver, proceeds);

        emit Withdrawn(_token, saleReceiver, proceeds);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFixedPriceV2
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @inheritdoc IFixedPriceV2
     */
    function setFeeManager(address _feeManager) external onlyOwner {
        emit FeeManagerSet(feeManager, _feeManager);
        feeManager = _feeManager;
    }

    /**
     * @inheritdoc IFixedPriceV2
     */
    function setFrameController(address _frameController) external onlyOwner {
        emit FrameControllerSet(frameController, _frameController);
        frameController = _frameController;
    }

    /**
     * @inheritdoc IFixedPriceV2
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                READ FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFixedPriceV2
     */
    function getFirstValidReserve(address _token) public view returns (uint256) {
        return LibMap.get(firstValidReserve, uint256(uint160(_token)));
    }

    /**
     * @inheritdoc IFixedPriceV2
     */
    function getLatestUpdate(address _token) public view returns (uint40) {
        return LibMap.get(latestUpdates, uint256(uint160(_token)));
    }

    /**
     * @inheritdoc IFixedPriceV2
     */
    function getSaleProceed(address _token) public view returns (uint128) {
        return LibMap.get(saleProceeds, uint256(uint160(_token)));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Purchases arbitrary amount of tokens at auction price and mints tokens to given account
     */
    function _buy(address _token, uint256 _reserveId, uint256 _amount, address _to) internal {
        uint256 length = reserves[_token].length;
        uint256 validReserve = getFirstValidReserve(_token);

        if (length == 0) revert InvalidToken();
        if (_reserveId >= length || _reserveId < validReserve) revert InvalidReserve();

        ReserveInfo storage reserve = reserves[_token][_reserveId];
        if (block.timestamp < reserve.startTime) revert NotStarted();
        if (block.timestamp > reserve.endTime) revert Ended();
        if (_amount > reserve.allocation) revert TooMany();
        if (_to == address(0)) revert AddressZero();

        uint256 price = _amount * prices[_token][_reserveId];
        (uint256 platformFee, uint256 mintFee, uint256 splitAmount) = IFeeManager(feeManager).calculateFee(
            _token,
            price,
            _amount
        );

        if (msg.value != price + platformFee) revert InvalidPayment();

        reserve.allocation -= _amount.safeCastTo128();

        if (splitAmount > 0) platformFee = platformFee - splitAmount;

        _setSaleProceeds(_token, getSaleProceed(_token) + (price - mintFee + splitAmount));

        SafeTransferLib.safeTransferETH(feeManager, mintFee + platformFee);

        IToken(_token).mint(_to, _amount, price);

        emit Purchase(_token, _reserveId, msg.sender, _amount, _to, price);
    }

    /**
     * @dev Sets timestamp of the latest update to token reserves
     */
    function _setLatestUpdate(address _token, uint256 _timestamp) internal {
        LibMap.set(latestUpdates, uint256(uint160(_token)), uint40(_timestamp));
    }

    /**
     * @dev Sets earliest valid reserve
     */
    function _setFirstValidReserve(address _token, uint256 _reserveId) internal {
        LibMap.set(firstValidReserve, uint256(uint160(_token)), uint40(_reserveId));
    }

    /**
     * @dev Sets the proceed amount from the token sale
     */
    function _setSaleProceeds(address _token, uint256 _amount) internal {
        LibMap.set(saleProceeds, uint256(uint160(_token)), uint128(_amount));
    }

    /**
     * @dev Gets the merkle root of a token reserve
     */
    function _getMerkleRoot(address _token, uint256 _reserveId) internal view override returns (bytes32) {
        return merkleRoots[_token][_reserveId];
    }
}
