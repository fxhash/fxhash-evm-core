// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibBitmap} from "solady/src/utils/LibBitmap.sol";
import {LibMap} from "solady/src/utils/LibMap.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IFixedPriceFrame} from "src/interfaces/IFixedPriceFrame.sol";
import {IToken} from "src/interfaces/IToken.sol";
import {ReserveInfo} from "src/lib/Structs.sol";

import {OPEN_EDITION_SUPPLY, TIME_UNLIMITED} from "src/utils/Constants.sol";

/**
 * @title FixedPrice
 * @author fx(hash)
 * @dev See the documentation in {IFixedPrice}
 */
contract FixedPriceFrame is IFixedPriceFrame, Ownable, Pausable {
    using SafeCastLib for uint256;

    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    address public minter;

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
     * @inheritdoc IFixedPriceFrame
     */
    mapping(address => uint256[]) public prices;

    /**
     * @inheritdoc IFixedPriceFrame
     */
    mapping(address => ReserveInfo[]) public reserves;

    /**
     * @inheritdoc IFixedPriceFrame
     */
    mapping(address => uint256) public maxAmountPerFid;

    /**
     * @inheritdoc IFixedPriceFrame
     */
    mapping(uint256 => mapping(address => uint256)) public mintedByFid;

    /*//////////////////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    modifier onlyMinter() {
        if (msg.sender != minter) revert Unauthorized();
        _;
    }

    constructor(address _minter) {
        minter = _minter;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFixedPriceFrame
     */
    function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable whenNotPaused {
        _buy(_token, _reserveId, _amount, _to);
    }

    function buyFrame(address _token, address _to, uint256 _reserveId, uint256 _fid) external whenNotPaused onlyMinter {
        if (_to == address(0)) revert ZeroAddress();
        if (mintedByFid[_fid][_token] == maxAmountPerFid[_token]) revert MaxAmountPerFidReached();

        mintedByFid[_fid][_token] += 1;

        _buy(_token, _reserveId, 1, _to);

        emit FrameMinted(_token, _to, _fid);
    }
    /**
     * @inheritdoc IFixedPriceFrame
     */

    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintDetails) external whenNotPaused {
        uint256 nextReserve = reserves[msg.sender].length;
        if (_reserve.allocation == 0) revert InvalidAllocation();
        (uint256 price, uint256 maxAmount) = abi.decode(_mintDetails, (uint256, uint256));

        prices[msg.sender].push(price);
        reserves[msg.sender].push(_reserve);
        maxAmountPerFid[msg.sender] = maxAmount;

        bool openEdition = _reserve.allocation == OPEN_EDITION_SUPPLY ? true : false;
        bool timeUnlimited = _reserve.endTime == TIME_UNLIMITED ? true : false;
        emit MintDetailsSet(msg.sender, nextReserve, price, _reserve, openEdition, timeUnlimited, maxAmount);
    }

    /**
     * @inheritdoc IFixedPriceFrame
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
     * @inheritdoc IFixedPriceFrame
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @inheritdoc IFixedPriceFrame
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    function setMinter(address _minter) external onlyOwner {
        minter = _minter;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                READ FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFixedPriceFrame
     */
    function getFirstValidReserve(address _token) public view returns (uint256) {
        return LibMap.get(firstValidReserve, uint256(uint160(_token)));
    }

    /**
     * @inheritdoc IFixedPriceFrame
     */
    function getLatestUpdate(address _token) public view returns (uint40) {
        return LibMap.get(latestUpdates, uint256(uint160(_token)));
    }

    /**
     * @inheritdoc IFixedPriceFrame
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
}
