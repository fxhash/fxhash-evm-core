// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1155.sol";
import "contracts/abstract/admin/AuthorizedCaller.sol";
import "hardhat/console.sol";

contract Marketplace is AuthorizedCaller {
    enum TokenType {
        ETH,
        ERC20,
        ERC721,
        ERC1155
    }

    struct Referrer {
        address referrer;
        uint256 share;
    }

    struct Currency {
        TokenType currencyType;
        bytes currencyData;
        bool enabled;
    }

    struct Asset {
        address assetContract;
        uint256 tokenId;
    }

    struct Listing {
        Asset asset;
        address seller;
        uint256 currency;
        uint256 amount;
    }

    struct Offer {
        bytes assets;
        address buyer;
        uint256 currency;
        uint256 amount;
    }

    struct TransferParams {
        address assetContract;
        uint256 tokenId;
        address owner;
        address receiver;
        uint256 amount;
        TokenType tokenType;
    }

    uint256 maxReferralShare;
    uint256 referralShare;
    uint256 listingSequence;
    uint256 offerSequence;
    uint256 platformFees;
    address treasury;

    mapping(address => bool) public assetContracts;
    mapping(uint256 => Currency) public currencies;
    mapping(uint256 => Listing) public listings;
    mapping(uint256 => Offer) public offers;

    event NewListing(
        address assetContract,
        uint256 tokenId,
        uint256 currency,
        uint256 amount,
        address seller
    );
    event ListingCanceled(uint256 listingId);
    event ListingBought(uint256 listingId, Referrer[] referrers, address buyer);
    event NewOffer(
        Asset[] assetList,
        uint256 amount,
        uint256 currency,
        address buyer
    );
    event OfferCanceled(uint256 offerId);
    event OfferAccepted(
        uint256 offerId,
        address assetContract,
        uint256 tokenId,
        Referrer[] referrers,
        address seller
    );

    constructor(
        address _admin,
        uint256 _maxReferralShare,
        uint256 _referralShare,
        uint256 _platformFees,
        address _treasury
    ) {
        maxReferralShare = _maxReferralShare;
        referralShare = _referralShare;
        platformFees = _platformFees;
        treasury = _treasury;
        listingSequence = 0;
        offerSequence = 0;
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function setAssetState(address _contract, bool _state) external onlyAdmin {
        assetContracts[_contract] = _state;
    }

    function setMaxReferralShare(uint256 _maxShare) external onlyAdmin {
        maxReferralShare = _maxShare;
    }

    function setReferralShare(uint256 _share) external onlyAdmin {
        referralShare = _share;
    }

    function setPlatformfees(uint256 _platformFees) external onlyAdmin {
        platformFees = _platformFees;
    }

    function setTreasury(address _treasury) external onlyAdmin {
        treasury = _treasury;
    }

    function addCurrency(
        uint256 _currencyId,
        Currency calldata _currency
    ) external onlyAdmin {
        currencies[_currencyId] = _currency;
    }

    function removeCurrency(uint256 _currencyId) external onlyAdmin {
        delete currencies[_currencyId];
    }

    function list(
        address _assetContract,
        uint256 _tokenId,
        uint256 _currency,
        uint256 _amount
    ) external {
        require(
            assetContracts[_assetContract] == true,
            "ASSET_CONTRACT_NOT_ENABLED"
        );
        require(currencies[_currency].enabled == true, "CURRENCY_DISABLED");
        require(_amount > 0, "AMOUNT_IS_0");

        listings[listingSequence] = Listing({
            asset: Asset({assetContract: _assetContract, tokenId: _tokenId}),
            seller: _msgSender(),
            currency: _currency,
            amount: _amount
        });
        listingSequence++;
        emit NewListing(
            _assetContract,
            _tokenId,
            _currency,
            _amount,
            _msgSender()
        );
    }

    function cancelListing(uint256 _listingId) external {
        Listing storage listing = listings[_listingId];
        require(listing.seller == _msgSender(), "NOT_AUTHORIZED");
        delete listings[_listingId];
        emit ListingCanceled(_listingId);
    }

    function buyListing(
        uint256 _listingId,
        Referrer[] calldata _referrers
    ) external payable {
        Listing memory listing = listings[_listingId];
        require(listing.seller != address(0), "LISTING_NOT_EXISTS");
        Currency memory currency = currencies[listing.currency];
        require(currency.enabled == true, "CURRENCY_DISABLED");
        if (currency.currencyType == TokenType.ETH) {
            require(msg.value == listing.amount, "AMOUNT_MISMATCH");
        }
        delete listings[_listingId];
        transfer(
            TransferParams({
                assetContract: listing.asset.assetContract,
                tokenId: listing.asset.tokenId,
                owner: listing.seller,
                receiver: _msgSender(),
                amount: 1,
                tokenType: TokenType.ERC721
            })
        );

        processPayments(
            listing.asset,
            currency,
            _referrers,
            _msgSender(),
            listing.seller,
            listing.amount
        );
        emit ListingBought(_listingId, _referrers, _msgSender());
    }

    function offer(
        Asset[] calldata _assetList,
        uint256 _amount,
        uint256 _currency
    ) external payable {
        Currency memory storedCurrency = currencies[_currency];
        require(storedCurrency.enabled == true, "CURRENCY_DISABLED");
        require(_amount > 0, "AMOUNT_IS_0");
        if (storedCurrency.currencyType == TokenType.ETH) {
            require(msg.value == _amount, "AMOUNT_MISMATCH");
        }
        require(_assetList.length > 0, "REQUIRE_AT_LEAST_1_ASSET");
        for (uint256 i = 0; i < _assetList.length; i++) {
            require(
                assetContracts[_assetList[i].assetContract] == true,
                "ASSET_CONTRACT_NOT_ENABLED"
            );
        }
        offers[offerSequence] = Offer({
            assets: abi.encode(_assetList),
            buyer: _msgSender(),
            amount: _amount,
            currency: _currency
        });
        offerSequence++;
        emit NewOffer(_assetList, _amount, _currency, _msgSender());
    }

    function cancelOffer(uint256 _offerId) external {
        Offer memory storedOffer = offers[_offerId];
        require(storedOffer.buyer == _msgSender(), "NOT_AUTHORIZED");
        delete offers[_offerId];
        if (currencies[storedOffer.currency].currencyType == TokenType.ETH) {
            payable(storedOffer.buyer).transfer(storedOffer.amount);
        }
        emit OfferCanceled(_offerId);
    }

    function acceptOffer(
        uint256 _offerId,
        address _assetContract,
        uint256 _tokenId,
        Referrer[] calldata _referrers
    ) external {
        Offer memory storedOffer = offers[_offerId];
        bool assetFound = false;
        Asset[] memory assets = abi.decode(storedOffer.assets, (Asset[]));
        for (uint256 i = 0; i < assets.length; i++) {
            if (
                assets[i].assetContract == _assetContract &&
                assets[i].tokenId == _tokenId
            ) {
                assetFound = true;
            }
        }
        require(assetFound, "INVALID_ASSET");
        delete offers[_offerId];
        Currency memory currency = currencies[storedOffer.currency];
        require(currency.enabled == true, "CURRENCY_DISABLED");
        transfer(
            TransferParams({
                assetContract: _assetContract,
                tokenId: _tokenId,
                owner: _msgSender(),
                receiver: storedOffer.buyer,
                amount: 1,
                tokenType: TokenType.ERC721
            })
        );

        processPayments(
            Asset({assetContract: _assetContract, tokenId: _tokenId}),
            currency,
            _referrers,
            storedOffer.buyer,
            _msgSender(),
            storedOffer.amount
        );
        emit OfferAccepted(
            _offerId,
            _assetContract,
            _tokenId,
            _referrers,
            _msgSender()
        );
    }

    function decodeCurrencyData(
        Currency memory _currency
    ) private pure returns (address, uint256) {
        if (_currency.currencyType == TokenType.ETH) {
            return (address(0), 0);
        } else if (_currency.currencyType == TokenType.ERC20) {
            return (abi.decode(_currency.currencyData, (address)), 0);
        } else if (
            _currency.currencyType == TokenType.ERC721 ||
            _currency.currencyType == TokenType.ERC1155
        ) {
            return abi.decode(_currency.currencyData, (address, uint256));
        } else {
            return (address(0), 0);
        }
    }

    function transfer(TransferParams memory _params) private {
        if (_params.tokenType == TokenType.ETH) {
            payable(_params.owner).transfer(_params.amount);
        } else if (_params.tokenType == TokenType.ERC20) {
            IERC20(_params.assetContract).transferFrom(
                _params.owner,
                _params.receiver,
                _params.amount
            );
        } else if (_params.tokenType == TokenType.ERC721) {
            IERC721(_params.assetContract).safeTransferFrom(
                _params.owner,
                _params.receiver,
                _params.tokenId
            );
        } else if (_params.tokenType == TokenType.ERC1155) {
            IERC1155(_params.assetContract).safeTransferFrom(
                _params.owner,
                _params.receiver,
                _params.amount,
                _params.tokenId,
                bytes("")
            );
        }
    }

    function processPayments(
        Asset memory _asset,
        Currency memory _currency,
        Referrer[] memory _referrers,
        address _sender,
        address _receiver,
        uint256 _amount
    ) private {
        (
            address decodedCurrencyContract,
            uint256 decodedCurrencyTokenId
        ) = decodeCurrencyData(_currency);
        uint256 paidRoyalties = payAssetRoyalties(
            _asset.assetContract,
            _asset.tokenId,
            _sender,
            _amount,
            decodedCurrencyContract,
            decodedCurrencyTokenId,
            _currency.currencyType
        );
        uint256 platformFeesForListing = (_amount * platformFees) / 10000;
        if (platformFeesForListing > 0) {
            if (_referrers.length > 0) {
                uint256 paidReferralFees = payReferrers(
                    _sender,
                    platformFeesForListing,
                    decodedCurrencyContract,
                    decodedCurrencyTokenId,
                    _currency.currencyType,
                    _referrers
                );
                transfer(
                    TransferParams({
                        assetContract: decodedCurrencyContract,
                        tokenId: decodedCurrencyTokenId,
                        owner: _sender,
                        receiver: treasury,
                        amount: platformFeesForListing - paidReferralFees,
                        tokenType: _currency.currencyType
                    })
                );
            } else {
                transfer(
                    TransferParams({
                        assetContract: decodedCurrencyContract,
                        tokenId: decodedCurrencyTokenId,
                        owner: _sender,
                        receiver: treasury,
                        amount: platformFeesForListing,
                        tokenType: _currency.currencyType
                    })
                );
            }
        }
        uint256 sellerAmount = _amount - platformFeesForListing - paidRoyalties;
        if (sellerAmount > 0) {
            transfer(
                TransferParams({
                    assetContract: decodedCurrencyContract,
                    tokenId: decodedCurrencyTokenId,
                    owner: _sender,
                    receiver: _receiver,
                    amount: sellerAmount,
                    tokenType: _currency.currencyType
                })
            );
        }
    }

    function payAssetRoyalties(
        address _contract,
        uint256 _tokenId,
        address _sender,
        uint256 _amount,
        address _currencyContract,
        uint256 _currencyTokenId,
        TokenType _tokenType
    ) private returns (uint256) {
        (address receiver, uint256 royaltiesAmount) = IERC2981(_contract)
            .royaltyInfo(_tokenId, _amount);
        transfer(
            TransferParams({
                assetContract: _currencyContract,
                tokenId: _currencyTokenId,
                owner: _sender,
                receiver: receiver,
                amount: royaltiesAmount,
                tokenType: _tokenType
            })
        );
        return royaltiesAmount;
    }

    function payReferrers(
        address _sender,
        uint256 _amount,
        address _currencyContract,
        uint256 _currencyTokenId,
        TokenType _tokenType,
        Referrer[] memory _referrers
    ) private returns (uint256) {
        uint256 paid = 0;
        uint256 sumShares = 0;
        for (uint256 i = 0; i < _referrers.length; i++) {
            uint256 referralAmount = (_amount * _referrers[i].share) / 10000;
            sumShares += _referrers[i].share;
            if (referralAmount > 0) {
                transfer(
                    TransferParams({
                        assetContract: _currencyContract,
                        tokenId: _currencyTokenId,
                        owner: _sender,
                        receiver: _referrers[i].referrer,
                        amount: referralAmount,
                        tokenType: _tokenType
                    })
                );
                paid += referralAmount;
            }
        }
        require(sumShares <= maxReferralShare, "TOO_HIGH_REFERRER_PCT");
        return paid;
    }
}
