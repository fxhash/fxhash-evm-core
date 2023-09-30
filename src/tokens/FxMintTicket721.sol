// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Burnable} from "openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {IAccessControl} from "openzeppelin/contracts/access/IAccessControl.sol";
import {IFxGenArt721, MintInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFxMintTicket721, TaxInfo} from "src/interfaces/IFxMintTicket721.sol";
import {Initializable} from "openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

import "src/utils/Constants.sol";

/**
 * @title FxMintTicket721
 * @notice See the documentation in {IFxMintTicket721}
 */
contract FxMintTicket721 is
    IFxMintTicket721,
    Initializable,
    ERC721,
    ERC721Burnable,
    Ownable,
    Pausable
{
    using Strings for uint256;

    /// @inheritdoc IFxMintTicket721
    address public genArt721;
    /// @inheritdoc IFxMintTicket721
    uint48 public totalSupply;
    /// @inheritdoc IFxMintTicket721
    uint48 public gracePeriod;
    /// @inheritdoc IFxMintTicket721
    string public baseURI;
    /// @inheritdoc IFxMintTicket721
    mapping(address => uint256) public balances;
    /// @inheritdoc IFxMintTicket721
    mapping(uint256 => TaxInfo) public taxes;

    /*//////////////////////////////////////////////////////////////////////////
                                  MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Modifier for restricting calls to only registered minters
     */
    modifier onlyMinter() {
        if (!isMinter(msg.sender)) revert UnregisteredMinter();
        _;
    }

    /**
     * @dev Modifier for restricting calls to only authorized accounts with given roles
     */
    modifier onlyRole(bytes32 _role) {
        address roleRegistry = IFxGenArt721(genArt721).roleRegistry();
        if (!IAccessControl(roleRegistry).hasRole(_role, msg.sender)) revert UnauthorizedAccount();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor() ERC721("FxMintTicket721", "TICKET") {}

    /*//////////////////////////////////////////////////////////////////////////
                                INITIALIZATION
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFxMintTicket721
    function initialize(
        address _owner,
        address _genArt721,
        uint48 _gracePeriod,
        string calldata _baseURI
    ) external initializer {
        genArt721 = _genArt721;
        gracePeriod = _gracePeriod;
        baseURI = _baseURI;
        _transferOwnership(_owner);

        emit TicketInitialized(_genArt721, _gracePeriod);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFxMintTicket721
    function mint(address _to, uint256 _amount, uint256 _payment)
        external
        onlyMinter
        whenNotPaused
    {
        // Calculates listing price per token
        uint256 listingPrice = _payment / _amount;

        unchecked {
            for (uint256 i; i < _amount; ++i) {
                // Increments supply and mints token to given wallet
                _mint(_to, ++totalSupply);

                // Sets initial tax info of token
                taxes[totalSupply] = TaxInfo(
                    uint128(block.timestamp) + gracePeriod,
                    uint128(block.timestamp) + gracePeriod,
                    uint128(listingPrice),
                    0
                );
            }
        }
    }

    /// @inheritdoc ERC721Burnable
    function burn(uint256 _tokenId)
        public
        virtual
        override(ERC721Burnable, IFxMintTicket721)
        onlyMinter
        whenNotPaused
    {
        super.burn(_tokenId);

        // Loads current tax info
        TaxInfo memory taxInfo = taxes[_tokenId];

        // Deletes tax info of token
        delete taxes[_tokenId];

        // Gets current daily tax amount
        uint256 dailyTax = getDailyTax(taxInfo.currentPrice);
        // Gets excess amount of taxes paid
        uint256 excessTax = getExcessTax(taxInfo.depositAmount, dailyTax);

        // Updates balance of token owner with any excess tax amount
        if (excessTax > 0) balances[_ownerOf(_tokenId)] += excessTax;
        // Updates balance of contract owner with deposit amount owed
        balances[owner()] += taxInfo.depositAmount - excessTax;
    }

    /// @inheritdoc IFxMintTicket721
    function claim(uint256 _tokenId, uint128 _newPrice) external payable {
        // Loads current tax info
        TaxInfo storage taxInfo = taxes[_tokenId];
        // Reverts if grace period of token is still active
        if (block.timestamp <= taxInfo.gracePeriod) revert GracePeriodActive();

        // Loads current tax information
        uint256 currentPrice = taxInfo.currentPrice;
        uint256 totalDeposit = taxInfo.depositAmount;
        uint256 foreclosureTime = taxInfo.foreclosureTime;
        address previousOwner = _ownerOf(_tokenId);

        // Gets current daily tax amount for current price
        uint256 currentDailyTax = getDailyTax(currentPrice);
        // Gets remaining deposit amount for current price
        uint256 remainingDeposit =
            getRemainingDeposit(currentDailyTax, foreclosureTime, totalDeposit);
        // Calculates deposit amount owed for current price
        uint256 depositOwed = totalDeposit - remainingDeposit;

        // Gets new daily tax amount for new price
        uint256 newDailyTax = getDailyTax(_newPrice);

        // Checks if foreclosure is active
        if (isForeclosed(_tokenId)) {
            // Gets current auction price
            uint256 auctionPrice = getAuctionPrice(currentPrice, foreclosureTime);
            // Reverts if payment amount is insufficient to auction price and new daily tax
            if (msg.value < auctionPrice + newDailyTax) revert InsufficientPayment();

            // Updates balance of contract owner
            balances[owner()] += totalDeposit + auctionPrice;
            // Sets new deposit amount based on auction price
            taxInfo.depositAmount = uint128(msg.value - auctionPrice);
        } else {
            // Reverts if payment amount if insufficient to current price and new daily tax
            if (msg.value < currentPrice + newDailyTax) revert InsufficientPayment();

            // Updates balances of contract owner and previous owner
            balances[owner()] += depositOwed;
            balances[previousOwner] += currentPrice + remainingDeposit;
            // Sets new deposit amount based on current price
            taxInfo.depositAmount = uint128(msg.value - currentPrice);
        }

        // Sets new tax info
        taxInfo.currentPrice = _newPrice;
        taxInfo.foreclosureTime =
            getForeclosureTime(newDailyTax, block.timestamp, taxInfo.depositAmount);

        // Transfers token from previous owner to new owner
        this.transferFrom(previousOwner, msg.sender, _tokenId);

        // Emits event for claiming ticket
        emit Claimed(_tokenId, msg.sender, _newPrice, msg.value);
    }

    /// @inheritdoc IFxMintTicket721
    function deposit(uint256 _tokenId) public payable {
        // Loads current tax info
        TaxInfo storage taxInfo = taxes[_tokenId];
        // Gets current daily tax amount
        uint256 dailyTax = getDailyTax(taxInfo.currentPrice);
        // Reverts if deposit amount is less than daily tax amount for one day
        if (msg.value < dailyTax) revert InsufficientDeposit();

        // Gets excess daily tax amount
        uint256 excessAmount = getExcessTax(msg.value, dailyTax);
        // Calculates total deposit amount
        uint256 depositAmount = msg.value - excessAmount;
        // Gets new foreclosure time based on deposit amount
        uint128 newForeclosure =
            getForeclosureTime(dailyTax, taxInfo.foreclosureTime, depositAmount);

        // Sets new tax info
        taxInfo.foreclosureTime = newForeclosure;
        taxInfo.depositAmount += uint128(depositAmount);

        // Emits event for depositing taxes
        emit Deposited(_tokenId, msg.sender, depositAmount, newForeclosure);

        // Transfers any excess tax amount back to depositer
        if (excessAmount > 0) SafeTransferLib.safeTransferETH(msg.sender, excessAmount);
    }

    /// @inheritdoc IFxMintTicket721
    function setPrice(uint256 _tokenId, uint128 _newPrice) public {
        // Reverts if caller is not owner of token
        if (_ownerOf(_tokenId) != msg.sender) revert NotAuthorized();
        // Reverts if token is foreclosed
        if (isForeclosed(_tokenId)) revert Foreclosure();
        // Reverts if new price is less than the minimum price
        if (_newPrice < MINIMUM_PRICE) revert InvalidPrice();

        // Loads current tax info
        TaxInfo storage taxInfo = taxes[_tokenId];
        uint128 foreclosureTime = taxInfo.foreclosureTime;

        // Gets daily tax amount for current price
        uint256 currentDailyTax = getDailyTax(taxInfo.currentPrice);
        // Gets remaining deposit amount for current price
        uint256 remainingDeposit =
            getRemainingDeposit(currentDailyTax, foreclosureTime, taxInfo.depositAmount);

        // Gets new daily tax amount for new price
        uint256 newDailyTax = getDailyTax(_newPrice);

        // Reverts if remaining deposit amount is insufficient to new daily tax amount
        if (remainingDeposit < newDailyTax) revert InsufficientDeposit();

        // Updates balance of contract owner with deposit amount owed
        balances[owner()] += (taxInfo.depositAmount - remainingDeposit);

        // Sets new tax info
        taxInfo.currentPrice = _newPrice;
        taxInfo.foreclosureTime = getForeclosureTime(newDailyTax, foreclosureTime, remainingDeposit);
        taxInfo.depositAmount = uint128(remainingDeposit);

        // Emits event for setting new price
        emit SetPrice(_tokenId, _newPrice, taxInfo.foreclosureTime, taxInfo.depositAmount);
    }

    /// @inheritdoc IFxMintTicket721
    function withdraw(address _to) external {
        uint256 balance = balances[_to];
        delete balances[_to];
        SafeTransferLib.safeTransferETH(_to, balance);

        emit Withdraw(msg.sender, _to, balance);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFxMintTicket721
    function setBaseURI(string calldata _uri) external onlyRole(ADMIN_ROLE) {
        baseURI = _uri;
    }

    /// @inheritdoc IFxMintTicket721
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /// @inheritdoc IFxMintTicket721
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                READ FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ERC721
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        _requireMinted(_tokenId);
        return string.concat(baseURI, _tokenId.toString());
    }

    /// @inheritdoc ERC721
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool)
    {
        return _operator == address(this) || super.isApprovedForAll(_owner, _operator);
    }

    /// @inheritdoc IFxMintTicket721
    function isForeclosed(uint256 _tokenId) public view returns (bool) {
        return block.timestamp >= taxes[_tokenId].foreclosureTime;
    }

    /// @inheritdoc IFxMintTicket721
    function isMinter(address _minter) public view returns (bool) {
        return IFxGenArt721(genArt721).isMinter(_minter);
    }

    /// @inheritdoc IFxMintTicket721
    function getAuctionPrice(uint256 _currentPrice, uint256 _foreclosureTime)
        public
        view
        returns (uint256)
    {
        uint256 timeElapsed = block.timestamp - _foreclosureTime;
        uint256 restingPrice = (_currentPrice * AUCTION_DECAY_RATE) / SCALING_FACTOR;
        // Returns resting price if more than one day has already passed
        if (timeElapsed > ONE_DAY) return restingPrice;
        uint256 totalDecay = _currentPrice - restingPrice;
        uint256 decayedAmount = (totalDecay / ONE_DAY) * timeElapsed;
        return _currentPrice - decayedAmount;
    }

    /// @inheritdoc IFxMintTicket721
    function getRemainingDeposit(
        uint256 _dailyTax,
        uint256 _foreclosureTime,
        uint256 _depositAmount
    ) public view returns (uint256) {
        uint256 depositEndTime = _foreclosureTime - getTaxDuration(_depositAmount, _dailyTax);
        // Returns total deposit amount if current time is less than end of deposit timestamp
        if (block.timestamp <= depositEndTime) return _depositAmount;
        uint256 elapsedDuration = block.timestamp - depositEndTime;
        uint256 amountOwed = (elapsedDuration * _dailyTax) / ONE_DAY;
        return (_depositAmount < amountOwed) ? _depositAmount : _depositAmount - amountOwed;
    }

    /// @inheritdoc IFxMintTicket721
    function getDailyTax(uint256 _currentPrice) public pure returns (uint256) {
        return (_currentPrice * DAILY_TAX_RATE) / SCALING_FACTOR;
    }

    /// @inheritdoc IFxMintTicket721
    function getExcessTax(uint256 _totalDeposit, uint256 _dailyTax) public pure returns (uint256) {
        uint256 daysCovered = _totalDeposit / _dailyTax;
        uint256 totalAmount = daysCovered * _dailyTax;
        return _totalDeposit - totalAmount;
    }

    /// @inheritdoc IFxMintTicket721
    function getForeclosureTime(uint256 _dailyTax, uint256 _foreclosureTime, uint256 _taxPayment)
        public
        pure
        returns (uint128)
    {
        uint256 secondsCovered = getTaxDuration(_taxPayment, _dailyTax);
        return uint128(_foreclosureTime + secondsCovered);
    }

    /// @inheritdoc IFxMintTicket721
    function getTaxDuration(uint256 _taxPayment, uint256 _dailyTax) public pure returns (uint256) {
        return (_taxPayment * ONE_DAY) / _dailyTax;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Tokens can only be transferred when either of these conditions is met:
     * 1) This contract executes transfer when token is claimed at auction price
     * 2) This contract executes transfer when token is claimed at listing price
     * 3) Contract owner executes public transfer when token is not in foreclosure
     * 4) Registered minter executes public burn when token is not in foreclosure
     */
    function _beforeTokenTransfer(
        address _from,
        address, /* _to */
        uint256 _tokenId,
        uint256 /* _batchSize */
    ) internal virtual override {
        // Check if token is being minted
        if (_from != address(0)) {
            // Reverts if token is foreclosed and caller is not this contract
            if (isForeclosed(_tokenId) && msg.sender != address(this)) revert Foreclosure();
            // Checks if token is not foreclosed
            if (!isForeclosed(_tokenId)) {
                // Returns if caller is either owner, this contract or registered minter
                if (msg.sender == address(this) || msg.sender == _from || isMinter(msg.sender)) {
                    return;
                }
                // Reverts otherwise
                revert NotAuthorized();
            }
        }
    }
}
