// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "forge-std/Test.sol";
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
        uint256 depositRemaining = getDepositRemaining(dailyTax, taxInfo.depositAmount, taxInfo.foreclosureTime);
        uint256 depositOwed = getDepositOwed(dailyTax, taxInfo.depositAmount, taxInfo.foreclosureTime);

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
            // Reverts if payment amount is not at least auction price plus one day's worth of taxes
            if (msg.value < auctionPrice + newDailyTax) revert InsufficientPayment();
            newDepositAmount = msg.value - auctionPrice;
            balances[owner()] += taxInfo.depositAmount + auctionPrice;
        } else {
            // Reverts if payment amount is not at least current listing price plus one day's worth of taxes
            if (msg.value < currentPrice + newDailyTax) revert InsufficientPayment();
            // Gets current daily tax amount based on current listing price
            uint256 currentDailyTax = getDailyTax(currentPrice);
            // Gets remaining deposit amount based on time used from total deposit amount
            uint256 depositOwed = getDepositOwed(currentDailyTax, taxInfo.depositAmount, taxInfo.foreclosureTime);
            uint256 depositRemaining = getDepositRemaining(
                currentDailyTax,
                taxInfo.depositAmount,
                taxInfo.foreclosureTime
            );
            balances[owner()] += depositOwed;
            balances[previousOwner] += currentPrice + depositRemaining;
            newDepositAmount = msg.value - currentPrice;
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
     */
    function deposit(uint256 _tokenId) public payable {
        console.log("deposit()");
        if (isForeclosed(_tokenId)) revert Foreclosure();
        TaxInfo storage taxInfo = taxes[_tokenId];
        uint256 dailyTax = getDailyTax(taxInfo.currentPrice);
        if (msg.value < dailyTax) revert InsufficientDeposit();

        console.log("CURRENT PRICE", taxInfo.currentPrice);
        console.log("DAILY TAX", dailyTax);

        uint256 excessAmount = getExcessTax(dailyTax, msg.value);
        uint256 depositAmount = msg.value - excessAmount;

        console.log("EXCESS AMOUNT", excessAmount);
        console.log("DEPOSIT AMOUNT", depositAmount);

        taxInfo.depositAmount += uint80(depositAmount);
        taxInfo.foreclosureTime = getNewForeclosure(dailyTax, depositAmount, taxInfo.foreclosureTime);
        if (excessAmount > 0) balances[msg.sender] += excessAmount;

        console.log("CURRENT BLOCK TIME", block.timestamp);
        console.log("CURRENT FORECLOSURE TIME", taxInfo.foreclosureTime);
        console.log("=================================================");

        emit Deposited(_tokenId, msg.sender, taxInfo.foreclosureTime, taxInfo.depositAmount);
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function setPrice(uint256 _tokenId, uint80 _newPrice) public {
        console.log("setPrice()");
        if (_ownerOf(_tokenId) != msg.sender) revert NotAuthorized();
        if (isForeclosed(_tokenId)) revert Foreclosure();
        if (_newPrice < MINIMUM_PRICE) revert InvalidPrice();

        TaxInfo storage taxInfo = taxes[_tokenId];
        uint48 foreclosureTime = taxInfo.foreclosureTime;
        uint256 currentDailyTax = getDailyTax(taxInfo.currentPrice);
        uint256 taxationStartTime = (block.timestamp > taxInfo.startTime) ? block.timestamp : taxInfo.startTime;
        uint256 depositOwed = getDepositOwed(currentDailyTax, taxInfo.depositAmount, foreclosureTime);
        uint256 depositRemaining = getDepositRemaining(currentDailyTax, taxInfo.depositAmount, foreclosureTime);
        uint256 newDailyTax = getDailyTax(_newPrice);

        console.log("CURRENT PRICE", taxInfo.currentPrice);
        console.log("CURRENT FORECLOSURE TIME", foreclosureTime);
        console.log("CURRENT DAILY TAX", currentDailyTax);
        console.log("REMAINING DEPOSIT", depositRemaining);
        console.log("NEW DAILY TAX", newDailyTax);

        if (depositRemaining < newDailyTax) revert InsufficientDeposit();

        balances[owner()] += depositOwed;
        taxInfo.currentPrice = _newPrice;
        taxInfo.depositAmount = uint80(depositRemaining);
        taxInfo.foreclosureTime = getNewForeclosure(newDailyTax, depositRemaining, taxationStartTime);

        console.log("DEPOSIT OWED", balances[owner()]);
        console.log("NEW PRICE", _newPrice);
        console.log("NEW DEPOSIT AMOUNT", taxInfo.depositAmount);
        console.log("TAXATION START TIME", taxationStartTime);
        console.log("CURRENT BLOCK TIME", block.timestamp);
        console.log("NEW FORECLOSURE TIME", taxInfo.foreclosureTime);
        console.log("=================================================");

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
    function getDepositOwed(
        uint256 _dailyTax,
        uint256 _depositAmount,
        uint256 _foreclosureTime
    ) public view returns (uint256) {
        console.log("amountOwed()");
        uint256 remainingDeposit = getDepositRemaining(_dailyTax, _depositAmount, _foreclosureTime);
        console.log("REMAINING DEPOSIT", remainingDeposit);
        console.log("DEPOSIT AMOUNT", _depositAmount);
        console.log("=================================================");
        return (_depositAmount < remainingDeposit) ? _depositAmount : _depositAmount - remainingDeposit;
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function getDepositRemaining(
        uint256 _dailyTax,
        uint256 _depositAmount,
        uint256 _foreclosureTime
    ) public view returns (uint256 remainingDeposit) {
        console.log("getRemainingDeposit()");
        uint256 secondsCovered = getTaxDuration(_dailyTax, _depositAmount);
        console.log("SECONDS COVERED", secondsCovered);
        uint256 depositStartTime = _foreclosureTime - secondsCovered;
        console.log("DEPOSIT START TIME", depositStartTime);
        // Returns total deposit amount if current time is less than deposit start timestamp
        if (block.timestamp <= depositStartTime) return _depositAmount;
        uint256 elapsedDuration = block.timestamp - depositStartTime;
        console.log("ELAPSED DURATION", elapsedDuration);
        remainingDeposit = (elapsedDuration * _dailyTax) / ONE_DAY;
        console.log("REMAINING DEPOSIT", remainingDeposit);
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
    function getExcessTax(uint256 _dailyTax, uint256 _depositAmount) public view returns (uint256) {
        console.log("getExcessTax()");
        uint256 daysCovered = _depositAmount / _dailyTax;
        console.log("DAYS COVERED", daysCovered);
        uint256 actualAmount = daysCovered * _dailyTax;
        console.log("ACTUAL AMOUNT", actualAmount);
        console.log("=================================================");
        return _depositAmount - actualAmount;
    }

    /**
     * @inheritdoc IFxMintTicket721
     */
    function getNewForeclosure(
        uint256 _dailyTax,
        uint256 _depositAmount,
        uint256 _currentForeclosure
    ) public view returns (uint48) {
        console.log("getNewForeclosure()");
        uint256 secondsCovered = getTaxDuration(_dailyTax, _depositAmount);
        console.log("SECONDS COVERED", secondsCovered);
        console.log("=================================================");
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
