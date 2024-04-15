// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibMap} from "solady/src/utils/LibMap.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";
import {SafeCastLib} from "solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IFarcasterFrame} from "src/interfaces/IFarcasterFrame.sol";
import {IToken} from "src/interfaces/IToken.sol";
import {ReserveInfo} from "src/lib/Structs.sol";

import {OPEN_EDITION_SUPPLY, TIME_UNLIMITED} from "src/utils/Constants.sol";

/**
 * @title FarcasterFrame
 * @author fx(hash)
 * @dev See the documentation in {IFarcasterFrame}
 */
contract FarcasterFrame is IFarcasterFrame, Ownable, Pausable {
    using SafeCastLib for uint256;

    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

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
     * @inheritdoc IFarcasterFrame
     */
    address public admin;

    /**
     * @inheritdoc IFarcasterFrame
     */
    mapping(address => uint256[]) public prices;

    /**
     * @inheritdoc IFarcasterFrame
     */
    mapping(address => ReserveInfo[]) public reserves;

    /**
     * @inheritdoc IFarcasterFrame
     */
    mapping(address => uint256) public maxAmounts;

    /**
     * @inheritdoc IFarcasterFrame
     */
    mapping(uint256 => mapping(address => uint256)) public totalMinted;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(address _admin) {
        admin = _admin;
        _initializeOwner(msg.sender);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFarcasterFrame
     */
    function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable whenNotPaused {
        _verifyTokenReserve(_token, _reserveId);
        uint256 price = _amount * prices[_token][_reserveId];
        if (msg.value != price) revert InvalidPayment();

        _setSaleProceeds(_token, getSaleProceeds(_token) + price);
        
        _buy(_token, _reserveId, price, _amount, _to);
    }

    /**
     * @inheritdoc IFarcasterFrame
     */
    function mint(address _token, uint256 _reserveId, uint256 _fId, address _to)
        external
        whenNotPaused
    {
        _verifyTokenReserve(_token, _reserveId);
        if (msg.sender != admin) revert Unauthorized();
        if (totalMinted[_fId][_token] == maxAmounts[_token]) revert MaxAmountExceeded();

        totalMinted[_fId][_token]++;
       
        _buy(_token, _reserveId, 0, 1, _to);

        emit FrameMinted(_token, _to, _fId);
    }

    /**
     * @inheritdoc IFarcasterFrame
     */
    function setMintDetails(ReserveInfo calldata _reserve, bytes calldata _mintDetails) external whenNotPaused {
        uint256 nextReserve = reserves[msg.sender].length;
        if (getLatestUpdate(msg.sender) != block.timestamp) {
            _setLatestUpdate(msg.sender, block.timestamp);
            _setFirstValidReserve(msg.sender, nextReserve);
        }

        if (_reserve.allocation == 0) revert InvalidAllocation();
        (uint256 price, uint256 maxAmount) = abi.decode(_mintDetails, (uint256, uint256));

        prices[msg.sender].push(price);
        reserves[msg.sender].push(_reserve);
        maxAmounts[msg.sender] = maxAmount;

        bool openEdition = _reserve.allocation == OPEN_EDITION_SUPPLY ? true : false;
        bool timeUnlimited = _reserve.endTime == TIME_UNLIMITED ? true : false;
        
        emit MintDetailsSet(msg.sender, nextReserve, price, _reserve, openEdition, timeUnlimited, maxAmount);
    }

    /**
     * @inheritdoc IFarcasterFrame
     */
    function withdraw(address _token) external whenNotPaused {
        uint256 proceeds = getSaleProceeds(_token);
        if (proceeds == 0) revert InsufficientFunds();

        address primaryReceiver = IToken(_token).primaryReceiver();
        _setSaleProceeds(_token, 0);

        SafeTransferLib.safeTransferETH(primaryReceiver, proceeds);

        emit Withdrawn(_token, primaryReceiver, proceeds);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFarcasterFrame
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @inheritdoc IFarcasterFrame
     */
    function setAdmin(address _admin) external onlyOwner {
        admin = _admin;
    }

    /**
     * @inheritdoc IFarcasterFrame
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                READ FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFarcasterFrame
     */
    function getFirstValidReserve(address _token) public view returns (uint256) {
        return LibMap.get(firstValidReserve, uint256(uint160(_token)));
    }

    /**
     * @inheritdoc IFarcasterFrame
     */
    function getLatestUpdate(address _token) public view returns (uint40) {
        return LibMap.get(latestUpdates, uint256(uint160(_token)));
    }

    /**
     * @inheritdoc IFarcasterFrame
     */
    function getSaleProceeds(address _token) public view returns (uint128) {
        return LibMap.get(saleProceeds, uint256(uint160(_token)));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Purchases arbitrary amount of tokens at fixed price and mints tokens to given account
     */
    function _buy(address _token, uint256 _reserveId, uint256 _price, uint256 _amount, address _to) internal {
        ReserveInfo storage reserve = reserves[_token][_reserveId];
        if (block.timestamp < reserve.startTime) revert NotStarted();
        if (block.timestamp > reserve.endTime) revert Ended();
        if (_amount > reserve.allocation) revert TooMany();
        if (_to == address(0)) revert AddressZero();

        reserve.allocation -= _amount.safeCastTo128();

        IToken(_token).mint(_to, _amount, _price);

        emit Purchase(_token, _reserveId, msg.sender, _amount, _to, _price);
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
     * @dev Verifies token and reserveId
     */
    function _verifyTokenReserve(address _token, uint256 _reserveId) internal view {
        uint256 length = reserves[_token].length;
        if (length == 0) revert InvalidToken();
        uint256 validReserve = getFirstValidReserve(_token);
        if (_reserveId >= length || _reserveId < validReserve) revert InvalidReserve();
    }
}
