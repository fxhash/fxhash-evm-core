// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC721, IERC721} from "openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Initializable} from "openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

import {IAccessControl} from "openzeppelin/contracts/access/IAccessControl.sol";
import {IERC4906} from "openzeppelin/contracts/interfaces/IERC4906.sol";
import {IERC5192} from "src/interfaces/IERC5192.sol";
import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";
import {IFxGenArt721, MintInfo, ProjectInfo, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFxMintTicket721, TaxInfo} from "src/interfaces/IFxMintTicket721.sol";
import {IMinter} from "src/interfaces/IMinter.sol";
import {IRenderer} from "src/interfaces/IRenderer.sol";

import "src/utils/Constants.sol";

/**
 * @title FxMintTicket721
 * @author fx(hash)
 * @notice See the documentation in {IFxMintTicket721}
 */
contract FxMintTicket721 is IFxMintTicket721, IERC4906, IERC5192, ERC721, Initializable, Ownable, Pausable {
    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxMintTicket721
     */
    address public immutable contractRegistry;

    /**
     * @inheritdoc IFxMintTicket721
     */
    address public immutable roleRegistry;

    /**
     * @inheritdoc IFxMintTicket721
     */
    address public genArt721;

    /**
     * @inheritdoc IFxMintTicket721
     */
    uint48 public totalSupply;

    /**
     * @inheritdoc IFxMintTicket721
     */
    uint48 public gracePeriod;

    /**
     * @inheritdoc IFxMintTicket721
     */
    bytes public baseURI;

    /**
     * @inheritdoc IFxMintTicket721
     */
    address public redeemer;

    /**
     * @inheritdoc IFxMintTicket721
     */
    address public renderer;

    /**
     * @inheritdoc IFxMintTicket721
     */
    address[] public activeMinters;

    /**
     * @inheritdoc IFxMintTicket721
     */
    mapping(address => uint256) public balances;

    /**
     * @inheritdoc IFxMintTicket721
     */
    mapping(address => uint8) public minters;

    /**
     * @inheritdoc IFxMintTicket721
     */
    mapping(uint256 => TaxInfo) public taxes;

    /*//////////////////////////////////////////////////////////////////////////
                                  MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Modifier for restricting calls to only callers with the specified role
     */
    modifier onlyRole(bytes32 _role) {
        if (!IAccessControl(roleRegistry).hasRole(_role, msg.sender)) revert UnauthorizedAccount();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Initializes FxContractRegistry and FxRoleRegistry
     */
    constructor(address _contractRegistry, address _roleRegistry) ERC721("FxMintTicket721", "FXTICKET") {
        contractRegistry = _contractRegistry;
        roleRegistry = _roleRegistry;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    INITIALIZER
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxMintTicket721
     */
    function initialize(
        address _owner,
        address _genArt721,
        address _redeemer,
        address _renderer,
        uint48 _gracePeriod,
        MintInfo[] calldata _mintInfo
    ) external initializer {
        genArt721 = _genArt721;
        redeemer = _redeemer;
        renderer = _renderer;
        gracePeriod = _gracePeriod;

        _initializeOwner(_owner);
        _registerMinters(_mintInfo);

        emit TicketInitialized(_genArt721, _redeemer, _renderer, _gracePeriod, _mintInfo);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxMintTicket721
     * @dev Steps:
     *  1. Check if caller is Redeemer contract
     *  2. Burn token from collection
     *  3. Delete tax info from storage
     *  4. Update balance of token owner with remaining excess tax if any amount exists
     *  5. Update balance of contract owner with total deposit amount minus excess tax amount
     */
    function burn(uint256 _tokenId) external whenNotPaused {
        if (msg.sender != redeemer) revert UnauthorizedRedeemer();

        _burn(_tokenId);
        TaxInfo memory taxInfo = taxes[_tokenId];
        delete taxes[_tokenId];

        uint256 dailyTax = getDailyTax(taxInfo.currentPrice);
        uint256 excessTax = getExcessTax(dailyTax, taxInfo.depositAmount);

        balances[owner()] += taxInfo.depositAmount - excessTax;
        if (excessTax > 0) balances[ownerOf(_tokenId)] += excessTax;
    }

    /**
     * @inheritdoc IFxMintTicket721
     * @dev Steps:
     *  1. Check if grace period is still active
     *  2. Check if new listing price is at least than minimum global price
     *  3. Check if current listing price is not greater than maximum price given to prevent front-running
     *  4. If token is foreclosed:
     *      - Check if payment amount is at least auction price plus one day's worth of new daily tax amount
     *      - Update balance of contract owner with deposit amount from storage plus auction price
     *  5. If token is not foreclosed:
     *      - Check if payment amount is at least current listing price plus one day's worth of new daily tax amount
     *      - Update balance of contract owner with deposit owed
     *      - Update balance of previous owner with current price plus any remaining deposit amount
     * 6. Update tax info values:
     *      - Set price to new listing price
     *      - Set deposit amount to new deposit amount minus excess tax amount
     *      - Set foreclosure time to current time plus time covered from new deposit amount
     * 7. Transfer token from previous owner to caller
     * 8. Update balance of caller with excess taxes if any amount exists
     */
    function claim(uint256 _tokenId, uint256 _maxPrice, uint80 _newPrice) external payable {
        TaxInfo storage taxInfo = taxes[_tokenId];
        if (block.timestamp <= taxInfo.gracePeriod) revert GracePeriodActive();
        if (_newPrice < MINIMUM_PRICE) revert InvalidPrice();
        uint256 currentPrice = taxInfo.currentPrice;
        if (currentPrice > _maxPrice) revert PriceExceeded();

        uint256 newDepositAmount;
        address previousOwner = _ownerOf(_tokenId);
        uint256 newDailyTax = getDailyTax(_newPrice);

        if (isForeclosed(_tokenId)) {
            uint256 auctionPrice = getAuctionPrice(currentPrice, taxInfo.foreclosureTime);
            if (msg.value < auctionPrice + newDailyTax) revert InsufficientPayment();
            newDepositAmount = msg.value - auctionPrice;
            balances[owner()] += taxInfo.depositAmount + auctionPrice;
        } else {
            if (msg.value < currentPrice + newDailyTax) revert InsufficientPayment();
            uint256 currentDailyTax = getDailyTax(currentPrice);
            uint256 remainingDeposit = getRemainingDeposit(
                currentDailyTax,
                taxInfo.depositAmount,
                taxInfo.foreclosureTime
            );
            uint256 depositOwed = taxInfo.depositAmount - remainingDeposit;
            newDepositAmount = msg.value - currentPrice;
            balances[owner()] += depositOwed;
            balances[previousOwner] += currentPrice + remainingDeposit;
        }

        uint256 excessAmount = getExcessTax(newDailyTax, newDepositAmount);
        taxInfo.currentPrice = _newPrice;
        taxInfo.depositAmount = uint80(newDepositAmount - excessAmount);
        taxInfo.foreclosureTime = getNewForeclosure(newDailyTax, taxInfo.depositAmount, block.timestamp);

        this.transferFrom(previousOwner, msg.sender, _tokenId);
        if (excessAmount > 0) balances[msg.sender] += excessAmount;

        emit Claimed(_tokenId, msg.sender, _newPrice, taxInfo.foreclosureTime, taxInfo.depositAmount, msg.value);
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function depositAndSetPrice(uint256 _tokenId, uint80 _newPrice) external payable {
        deposit(_tokenId);
        setPrice(_tokenId, _newPrice);
    }

    /**
     * @inheritdoc IFxMintTicket721
     * @dev Steps:
     *  1. Check if caller is a registered minter
     *  2. Set current price to max value of mint price and minimum global price
     *  3. Mint token to given wallet
     *  4. Increment counter
     *  5. Initialize tax info values:
     *      - Set grace period to current time plus grace period
     *      - Set foreclosure time to current time plus grace period
     *      - Set current price to mint price
     *      - Set deposit amount to zero
     *  6. Set total supply to counter
     */
    function mint(address _to, uint256 _amount, uint256 _payment) external whenNotPaused {
        if (minters[msg.sender] != TRUE) revert UnregisteredMinter();

        uint256 currentPrice = _payment / _amount;
        currentPrice = (currentPrice < MINIMUM_PRICE) ? MINIMUM_PRICE : currentPrice;

        uint48 currentId = totalSupply;
        for (uint256 i; i < _amount; ++i) {
            _mint(_to, ++currentId);

            emit Locked(currentId);

            taxes[currentId] = TaxInfo(
                uint48(block.timestamp) + gracePeriod,
                uint48(block.timestamp) + gracePeriod,
                uint80(currentPrice),
                0
            );
        }
        totalSupply = currentId;
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function withdraw(address _to) external {
        uint256 balance = balances[_to];
        delete balances[_to];
        SafeTransferLib.safeTransferETH(_to, balance);

        emit Withdraw(msg.sender, _to, balance);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxMintTicket721
     * @dev Steps:
     *  1. Check if token is foreclosed
     *  2. Check if deposit amount is at least one day's worth of daily taxes
     *  3. Update tax info values:
     *      - Set deposit amount to payment value
     *      - Set foreclosure time to current foreclosure plus new time covered from actual deposit amount
     *  4. Update caller balance with excess taxes if any amount exists
     */
    function deposit(uint256 _tokenId) public payable {
        if (isForeclosed(_tokenId)) revert Foreclosure();
        TaxInfo storage taxInfo = taxes[_tokenId];
        uint256 dailyTax = getDailyTax(taxInfo.currentPrice);
        if (msg.value < dailyTax) revert InsufficientDeposit();

        uint256 excessAmount = getExcessTax(dailyTax, msg.value);
        uint256 depositAmount = msg.value - excessAmount;

        taxInfo.depositAmount += uint80(depositAmount);
        taxInfo.foreclosureTime = getNewForeclosure(dailyTax, depositAmount, taxInfo.foreclosureTime);
        if (excessAmount > 0) balances[msg.sender] += excessAmount;

        emit Deposited(_tokenId, msg.sender, taxInfo.foreclosureTime, taxInfo.depositAmount);
    }

    /**
     * @inheritdoc IFxMintTicket721
     * @dev Steps:
     *  1. Check if caller is owner of token
     *  2. Check if token is foreclosed
     *  3. Check if new listing price is at least minimum global price
     *  4. Check if remaining deposit amount based on new price is at least one day's worth of new daily tax amount
     *  5. Update valance of contract owner with deposit amount owed
     *  6. Update tax info values:
     *      - Set current price to new price
     *      - Set deposit amount to remaining deposit amount
     *      - Set foreclosure time to current foreclosure time plus new time covered from remaining deposit amount
     */
    function setPrice(uint256 _tokenId, uint80 _newPrice) public {
        if (_ownerOf(_tokenId) != msg.sender) revert NotAuthorized();
        if (isForeclosed(_tokenId)) revert Foreclosure();
        if (_newPrice < MINIMUM_PRICE) revert InvalidPrice();

        TaxInfo storage taxInfo = taxes[_tokenId];
        uint48 foreclosureTime = taxInfo.foreclosureTime;
        uint256 currentDailyTax = getDailyTax(taxInfo.currentPrice);
        uint256 remainingDeposit = getRemainingDeposit(currentDailyTax, taxInfo.depositAmount, foreclosureTime);
        uint256 newDailyTax = getDailyTax(_newPrice);

        if (remainingDeposit < newDailyTax) revert InsufficientDeposit();

        balances[owner()] += taxInfo.depositAmount - remainingDeposit;
        taxInfo.currentPrice = _newPrice;
        taxInfo.depositAmount = uint80(remainingDeposit);
        taxInfo.foreclosureTime = getNewForeclosure(newDailyTax, remainingDeposit, foreclosureTime);

        emit SetPrice(_tokenId, _newPrice, taxInfo.depositAmount, taxInfo.foreclosureTime);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxMintTicket721
     */
    function registerMinters(MintInfo[] calldata _mintInfo) external onlyOwner {
        (, ProjectInfo memory projectInfo) = IFxGenArt721(genArt721).issuerInfo();
        if (projectInfo.mintEnabled) revert MintActive();
        uint256 length = activeMinters.length;
        for (uint256 i; i < length; ++i) {
            address minter = activeMinters[i];
            minters[minter] = FALSE;
        }
        delete activeMinters;
        _registerMinters(_mintInfo);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                METADATA FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxMintTicket721
     */
    function setBaseURI(bytes calldata _uri) external onlyRole(METADATA_ROLE) {
        baseURI = _uri;
        emit BaseURIUpdated(_uri);
        emit BatchMetadataUpdate(1, totalSupply);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                MODERATOR FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxMintTicket721
     */
    function pause() external onlyRole(MODERATOR_ROLE) {
        _pause();
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function unpause() external onlyRole(MODERATOR_ROLE) {
        _unpause();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                READ FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxMintTicket721
     */
    function contractURI() external view returns (string memory) {
        return IRenderer(renderer).contractURI();
    }

    /**
     * @inheritdoc IERC5192
     */
    function locked(uint256 _tokenId) external view returns (bool) {
        _requireMinted(_tokenId);
        return true;
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function primaryReceiver() external view returns (address) {
        return IFxGenArt721(genArt721).primaryReceiver();
    }

    /**
     * @inheritdoc ERC721
     */
    function isApprovedForAll(address _owner, address _operator) public view override(ERC721, IERC721) returns (bool) {
        return _operator == address(this) || minters[_operator] == TRUE || super.isApprovedForAll(_owner, _operator);
    }

    /**
     * @inheritdoc ERC721
     */
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        _requireMinted(_tokenId);
        bytes memory data = abi.encode(baseURI, address(0), bytes32(0), bytes(""));
        return IRenderer(renderer).tokenURI(_tokenId, data);
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function getAuctionPrice(uint256 _currentPrice, uint256 _foreclosureTime) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - _foreclosureTime;
        uint256 restingPrice = (_currentPrice * AUCTION_DECAY_RATE) / SCALING_FACTOR;
        // Returns resting price if more than one day has already passed
        if (timeElapsed > ONE_DAY) return restingPrice;
        uint256 totalDecay = _currentPrice - restingPrice;
        uint256 decayedAmount = (totalDecay / ONE_DAY) * timeElapsed;
        return _currentPrice - decayedAmount;
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function getRemainingDeposit(
        uint256 _dailyTax,
        uint256 _depositAmount,
        uint256 _foreclosureTime
    ) public view returns (uint256) {
        uint256 taxDuration = getTaxDuration(_dailyTax, _depositAmount);
        uint256 depositEndTime = _foreclosureTime - taxDuration;
        // Returns total deposit amount if current time is less than end of deposit timestamp
        if (block.timestamp <= depositEndTime) return _depositAmount;
        uint256 elapsedDuration = block.timestamp - depositEndTime;
        uint256 amountOwed = (elapsedDuration * _dailyTax) / ONE_DAY;
        return (_depositAmount < amountOwed) ? _depositAmount : _depositAmount - amountOwed;
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function isForeclosed(uint256 _tokenId) public view returns (bool) {
        return block.timestamp >= taxes[_tokenId].foreclosureTime;
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function getDailyTax(uint256 _currentPrice) public pure returns (uint256) {
        return (_currentPrice * DAILY_TAX_RATE) / SCALING_FACTOR;
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function getExcessTax(uint256 _dailyTax, uint256 _depositAmount) public pure returns (uint256) {
        uint256 daysCovered = _depositAmount / _dailyTax;
        uint256 actualAmount = daysCovered * _dailyTax;
        return _depositAmount - actualAmount;
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function getNewForeclosure(
        uint256 _dailyTax,
        uint256 _depositAmount,
        uint256 _currentForeclosure
    ) public pure returns (uint48) {
        uint256 secondsCovered = getTaxDuration(_dailyTax, _depositAmount);
        return uint48(_currentForeclosure + secondsCovered);
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function getTaxDuration(uint256 _dailyTax, uint256 _depositAmount) public pure returns (uint256) {
        return (_depositAmount * ONE_DAY) / _dailyTax;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Registers arbitrary number of minter contracts and sets their reserves
     */
    function _registerMinters(MintInfo[] memory _mintInfo) internal {
        address minter;
        uint64 startTime;
        uint128 totalAllocation;
        ReserveInfo memory reserveInfo;
        (, ProjectInfo memory projectInfo) = IFxGenArt721(genArt721).issuerInfo();
        uint120 maxSupply = projectInfo.maxSupply;
        uint64 earliestStartTime = projectInfo.earliestStartTime;
        for (uint256 i; i < _mintInfo.length; ++i) {
            minter = _mintInfo[i].minter;
            reserveInfo = _mintInfo[i].reserveInfo;
            startTime = reserveInfo.startTime;

            if (!IAccessControl(roleRegistry).hasRole(MINTER_ROLE, minter)) revert UnauthorizedMinter();
            if (startTime == 0) {
                reserveInfo.startTime = (block.timestamp > earliestStartTime)
                    ? uint64(block.timestamp)
                    : earliestStartTime;
            } else if (startTime < earliestStartTime) {
                revert InvalidStartTime();
            }
            if (reserveInfo.endTime < startTime) revert InvalidEndTime();
            if (maxSupply != OPEN_EDITION_SUPPLY) totalAllocation += reserveInfo.allocation;

            minters[minter] = TRUE;
            activeMinters.push(minter);
            IMinter(minter).setMintDetails(reserveInfo, _mintInfo[i].params);
        }

        if (maxSupply != OPEN_EDITION_SUPPLY) {
            uint256 remainingSupply = IFxGenArt721(genArt721).remainingSupply();
            if (totalAllocation > remainingSupply) revert AllocationExceeded();
        }
    }

    /**
     * @dev Tokens can only be transferred when either of these conditions is met:
     * 1) This contract executes transfer when token is in foreclosure and claimed at auction price
     * 2) This contract executes transfer when token is not in foreclosure and claimed at listing price
     * 3) Token owner executes transfer when token is not in foreclosure
     * 4) Registered minter contract executes burn when token is not in foreclosure
     */
    function _beforeTokenTransfer(address _from, address, uint256 _tokenId, uint256) internal view override {
        // Checks if token is not being minted
        if (_from != address(0)) {
            // Reverts if token is foreclosed and caller is not this contract
            if (isForeclosed(_tokenId) && msg.sender != address(this)) revert Foreclosure();
            // Checks if token is not foreclosed
            if (!isForeclosed(_tokenId)) {
                // Returns if caller is this contract, current token owner or redeemer contract
                if (msg.sender == address(this) || msg.sender == _from || redeemer == msg.sender) {
                    return;
                }
                // Reverts otherwise
                revert NotAuthorized();
            }
        }
    }

    /**
     * @dev Checks if creator is verified by the system
     */
    function _isVerified(address _creator) internal view returns (bool) {
        return (IAccessControl(roleRegistry).hasRole(CREATOR_ROLE, _creator));
    }
}
