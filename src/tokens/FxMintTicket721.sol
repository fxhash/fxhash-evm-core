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
     */
    function burn(uint256 _tokenId) external whenNotPaused {
        // Reverts if caller is not redeemer contract
        if (msg.sender != redeemer) revert UnauthorizedRedeemer();

        // Burns token from collection
        _burn(_tokenId);

        // Loads tax info into memory
        TaxInfo memory taxInfo = taxes[_tokenId];

        // Deletes tax info from storage
        delete taxes[_tokenId];

        // Calculates remaining deposit amount to return to token owner
        uint256 dailyTax = getDailyTax(taxInfo.currentPrice);
        (uint256 depositOwed, uint256 depositRemaining) = getDepositAmounts(
            dailyTax,
            taxInfo.depositAmount,
            taxInfo.foreclosureTime
        );

        // Updates owner balance with deposit amount owed
        balances[owner()] += depositOwed;

        // Updates token owner balance with returning deposit if any amount exists
        if (depositRemaining > 0) balances[ownerOf(_tokenId)] += depositRemaining;
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function claim(uint256 _tokenId, uint256 _maxPrice, uint80 _newPrice) external payable {
        TaxInfo storage taxInfo = taxes[_tokenId];
        // Reverts if taxation start time has not begun
        if (block.timestamp < taxInfo.startTime) revert GracePeriodActive();
        // Reverts if new price is not at least minimum global price
        if (_newPrice < MINIMUM_PRICE) revert InvalidPrice();
        uint256 currentPrice = taxInfo.currentPrice;
        // Reverts if current listing price is greater than maximum price given to prevent front-running
        if (currentPrice > _maxPrice) revert PriceExceeded();

        uint256 newDepositAmount;
        address previousOwner = _ownerOf(_tokenId);

        // Gets new daily tax amount based on new listing price
        uint256 newDailyTax = getDailyTax(_newPrice);

        if (isForeclosed(_tokenId)) {
            uint256 auctionPrice = getAuctionPrice(currentPrice, taxInfo.foreclosureTime);
            // Reverts if payment amount is not at least auction price plus new daily tax amount
            if (msg.value < auctionPrice + newDailyTax) revert InsufficientPayment();

            // Sets new deposit amount based on payment minus current listing price
            newDepositAmount = msg.value - auctionPrice;

            // Updates balance of contract owner with total deposit amount and auction price
            balances[owner()] += taxInfo.depositAmount + auctionPrice;
        } else {
            // Reverts if payment amount is not at least current listing price plus new daily tax amount
            if (msg.value < currentPrice + newDailyTax) revert InsufficientPayment();

            // Sets new deposit amount based on payment minus current listing price
            newDepositAmount = msg.value - currentPrice;

            // Gets current daily tax amount based on current listing price
            uint256 currentDailyTax = getDailyTax(currentPrice);
            // Gets deposit amount owed and remaining based on time accrued from total deposit
            (uint256 depositOwed, uint256 depositRemaining) = getDepositAmounts(
                currentDailyTax,
                taxInfo.depositAmount,
                taxInfo.foreclosureTime
            );

            // Updates balances of contract owner and previous token owner
            balances[owner()] += depositOwed;
            balances[previousOwner] += currentPrice + depositRemaining;
        }

        // Gets excess tax amount
        uint256 excessAmount = getExcessTax(newDailyTax, newDepositAmount);

        // Sets updated tax info
        taxInfo.currentPrice = _newPrice;
        taxInfo.depositAmount = uint80(newDepositAmount - excessAmount);
        taxInfo.foreclosureTime = getNewForeclosure(newDailyTax, taxInfo.depositAmount, block.timestamp);

        // Transfers token from previous owner to caller
        this.transferFrom(previousOwner, msg.sender, _tokenId);

        // Updates balance of caller with excess tax if any amount exists
        if (excessAmount > 0) balances[msg.sender] += excessAmount;

        // Emits event for claiming token
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
     */
    function mint(address _to, uint256 _amount, uint256 _payment) external whenNotPaused {
        // Reverts if caller is not a registered minter contract
        if (minters[msg.sender] != TRUE) revert UnregisteredMinter();

        // Calculates individual listing price
        uint256 currentPrice = _payment / _amount;
        currentPrice = (currentPrice < MINIMUM_PRICE) ? MINIMUM_PRICE : currentPrice;

        uint48 currentId = totalSupply;
        for (uint256 i; i < _amount; ++i) {
            // Mints token to caller
            _mint(_to, ++currentId);

            // Emits event for partial SBT
            emit Locked(currentId);

            // Initialized token info
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
    function setStartTime(uint256 _tokenId) external {
        // Reverts if caller is not owner of token
        if (_ownerOf(_tokenId) != msg.sender) revert NotAuthorized();
        TaxInfo storage taxInfo = taxes[_tokenId];
        // Reverts if taxation start time has already begun
        if (block.timestamp >= taxInfo.startTime) revert GracePeriodInactive();
        // Reverts if foreclosure time is less than one day
        if (taxInfo.foreclosureTime < block.timestamp + ONE_DAY) revert InsufficientDeposit();

        taxInfo.startTime += uint48(block.timestamp);
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
     */
    function deposit(uint256 _tokenId) public payable {
        // Reverts if token is foreclosed
        if (isForeclosed(_tokenId)) revert Foreclosure();
        TaxInfo storage taxInfo = taxes[_tokenId];
        // Gets daily tax amount based on current listing price
        uint256 dailyTax = getDailyTax(taxInfo.currentPrice);
        // Reverts if deposit amount is less than daily tax amount
        if (msg.value < dailyTax) revert InsufficientDeposit();

        // Calculates actual deposit amount due to any excess tax deposited
        uint256 excessAmount = getExcessTax(dailyTax, msg.value);
        uint256 depositAmount = msg.value - excessAmount;

        // Sets updated tax info
        taxInfo.depositAmount += uint80(depositAmount);
        taxInfo.foreclosureTime = getNewForeclosure(dailyTax, depositAmount, taxInfo.foreclosureTime);

        // Updates balance of caller with excess tax if any amount exists
        if (excessAmount > 0) balances[msg.sender] += excessAmount;

        // Emits event for deposit taxes
        emit Deposited(_tokenId, msg.sender, taxInfo.foreclosureTime, taxInfo.depositAmount);
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function setPrice(uint256 _tokenId, uint80 _newPrice) public {
        // Reverts if caller is not owner of token
        if (_ownerOf(_tokenId) != msg.sender) revert NotAuthorized();
        // Reverts if token is foreclosed
        if (isForeclosed(_tokenId)) revert Foreclosure();
        // Reverts if new listing price is less than minimum possible price
        if (_newPrice < MINIMUM_PRICE) revert InvalidPrice();

        TaxInfo storage taxInfo = taxes[_tokenId];
        uint48 foreclosureTime = taxInfo.foreclosureTime;
        // Checks maximum timestamp to get actual taxation start time
        uint256 taxationStartTime = (block.timestamp > taxInfo.startTime) ? block.timestamp : taxInfo.startTime;

        // Gets current daily tax amount based on current listing price
        uint256 currentDailyTax = getDailyTax(taxInfo.currentPrice);
        // Get new daily tax amount based on new listing price
        uint256 newDailyTax = getDailyTax(_newPrice);
        // Gets deposit amount owed and remaining for time accrued from total deposit
        (uint256 depositOwed, uint256 depositRemaining) = getDepositAmounts(
            currentDailyTax,
            taxInfo.depositAmount,
            foreclosureTime
        );

        // Reverts if remaining deposit amount is less than new daily tax amount
        if (depositRemaining < newDailyTax) revert InsufficientDeposit();

        // Updates balance of contract owner with deposit amount owed
        balances[owner()] += depositOwed;

        // Sets update tax info
        taxInfo.currentPrice = _newPrice;
        taxInfo.depositAmount = uint80(depositRemaining);
        taxInfo.foreclosureTime = getNewForeclosure(newDailyTax, depositRemaining, taxationStartTime);

        // Emits event for setting new listing price
        emit SetPrice(_tokenId, _newPrice, taxInfo.foreclosureTime, taxInfo.depositAmount);
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
        if (timeElapsed > ONE_DAY) return restingPrice;

        uint256 totalDecay = _currentPrice - restingPrice;
        uint256 decayedAmount = (totalDecay / ONE_DAY) * timeElapsed;
        return _currentPrice - decayedAmount;
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function getDepositAmounts(
        uint256 _dailyTax,
        uint256 _depositAmount,
        uint256 _foreclosureTime
    ) public view returns (uint256 depositOwed, uint256 depositRemaining) {
        uint256 secondsCovered = getTaxDuration(_dailyTax, _depositAmount);
        uint256 depositStartTime = _foreclosureTime - secondsCovered;
        if (block.timestamp <= depositStartTime) {
            depositRemaining = _depositAmount;
        } else {
            uint256 elapsedDuration = block.timestamp - depositStartTime;
            depositRemaining = (elapsedDuration * _dailyTax) / ONE_DAY;
            depositOwed = (_depositAmount < depositRemaining) ? _depositAmount : _depositAmount - depositRemaining;
        }
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
