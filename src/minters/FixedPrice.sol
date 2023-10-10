// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IFixedPrice} from "src/interfaces/IFixedPrice.sol";
import {IFxGenArt721, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IMinter} from "src/interfaces/IMinter.sol";
import {Allowlist} from "src/minters/extensions/Allowlist.sol";
import {MintPass} from "src/minters/extensions/MintPass.sol";

/**
 * @title FixedPrice
 * @notice See the documentation in {IFixedPrice}
 */
contract FixedPrice is MintPass, Allowlist, IFixedPrice {
    using SafeCastLib for uint256;

    /// @inheritdoc IFixedPrice
    mapping(address => uint256[]) public prices;

    /// @inheritdoc IFixedPrice
    mapping(address => mapping(uint256 => bytes32)) public merkleRoots;

    /// @inheritdoc IFixedPrice
    mapping(address => mapping(uint256 => address)) public signingAuthorities;

    /// @inheritdoc IFixedPrice
    mapping(address => ReserveInfo[]) public reserves;

    /// @inheritdoc IFixedPrice
    mapping(address => uint256) public saleProceeds;

    /// @inheritdoc IMinter
    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintDetails) external {
        if (_reserve.allocation == 0) revert InvalidAllocation();
        (uint256 price, bytes32 merkleRoot, address signer) = abi.decode(_mintDetails, (uint256, bytes32, address));

        if (price == 0) revert InvalidPrice();
        uint256 reserveId = reserves[msg.sender].length;
        if (merkleRoot != bytes32(0)) {
            merkleRoots[msg.sender][reserveId] = merkleRoot;
        }
        if (signer != address(0)) {
            signingAuthorities[msg.sender][reserveId] = signer;
        }
        prices[msg.sender].push(price);
        reserves[msg.sender].push(_reserve);
        emit MintDetailsSet(msg.sender, reserveId, price, _reserve);
    }

    /// @inheritdoc IFixedPrice
    function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable {
        bytes32 merkleRoot = merkleRoots[_token][_reserveId];
        address signer = signingAuthorities[_token][_reserveId];
        if (!(merkleRoot == bytes32(0) || signer == address(0))) revert NoPublicMint();
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

    function buyAllowlist(
        address _token,
        uint256 _reserveId,
        address _to,
        bytes32[][] calldata _proofs
    ) external payable {
        bytes32 merkleRoot = merkleRoots[_token][_reserveId];
        if (merkleRoot == bytes32(0)) revert NoAllowlist();
        uint256 amount = _proofs.length;
        _buy(_token, _reserveId, amount, _to);
    }

    function buyMintPass(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable {
        address signer = signingAuthorities[_token][_reserveId];
        if (signer == address(0)) revert NoSigningAuthority();
        _buy(_token, _reserveId, _amount, _to);
    }

    /// @inheritdoc IFixedPrice
    function withdraw(address _token) external {
        uint256 proceeds = saleProceeds[_token];
        if (proceeds == 0) revert InsufficientFunds();
        (, address saleReceiver) = IFxGenArt721(_token).issuerInfo();
        delete saleProceeds[_token];
        SafeTransferLib.safeTransferETH(saleReceiver, proceeds);
        emit Withdrawn(_token, saleReceiver, proceeds);
    }

    function _buy(address _token, uint256 _reserveId, uint256 _amount, address _to) internal {}

    function _getMerkleRoot(address _token) internal view override returns (bytes32) {}

    function _isSigningAuthority(address _signer) internal view override returns (bool) {}
}
