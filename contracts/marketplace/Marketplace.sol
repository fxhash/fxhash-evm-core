// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1155.sol";
import "contracts/abstract/admin/AuthorizedCaller.sol";

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
        Asset[] assets;
        address buyer;
        uint256 currency;
        uint256 amount;
    }

    uint256 maxReferralShare;
    uint256 referralShare;
    uint256 listingSequence;
    uint256 offerSequence;
    uint256 platformFees;
    address treasury;

    mapping(address => bool) assetContracts;
    mapping(uint256 => Currency) currencies;
    mapping(uint256 => Listing) listings;
    mapping(uint256 => Offer) offers;

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
    }

    function setAssetState(
        address _contract,
        bool _state
    ) external onlyAuthorizedCaller {
        assetContracts[_contract] = _state;
    }

    function setMaxReferralShare(
        uint256 _maxShare
    ) external onlyAuthorizedCaller {
        maxReferralShare = _maxShare;
    }

    function setReferralShare(uint256 _share) external onlyAuthorizedCaller {
        referralShare = _share;
    }

    function setPlatformfees(
        uint256 _platformFees
    ) external onlyAuthorizedCaller {
        platformFees = _platformFees;
    }

    function setTreasury(address _treasury) external onlyAuthorizedCaller {
        treasury = _treasury;
    }

    function addCurrency(
        uint256 _currencyId,
        Currency calldata _currency
    ) external onlyAuthorizedCaller {
        currencies[_currencyId] = _currency;
    }

    function removeCurrency(uint256 _currencyId) external onlyAuthorizedCaller {
        delete currencies[_currencyId];
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

    function transfer(
        address _contract,
        uint256 _tokenId,
        address _owner,
        address _receiver,
        uint256 _amount,
        TokenType _tokenType
    ) private {
        if (_tokenType == TokenType.ETH) {
            payable(_owner).transfer(_amount);
        } else if (_tokenType == TokenType.ERC20) {
            IERC20(_contract).transferFrom(_owner, _receiver, _amount);
        } else if (_tokenType == TokenType.ERC721) {
            IERC721(_contract).safeTransferFrom(_owner, _receiver, _tokenId);
        } else if (_tokenType == TokenType.ERC1155) {
            IERC1155(_contract).safeTransferFrom(
                _owner,
                _receiver,
                _amount,
                _tokenId,
                bytes("")
            );
        }
    }

    function payAssetRoyalties(
        address _contract,
        uint256 _tokenId,
        uint256 _amount
    ) private returns (uint256) {
        (address receiver, uint256 royaltiesAmount) = IERC2981(_contract)
            .royaltyInfo(_tokenId, _amount);
        payable(receiver).transfer(royaltiesAmount);
        return royaltiesAmount;
    }

    function payReferrers(
        uint256 _amount,
        Referrer[] calldata _referrers
    ) private returns (uint256) {
        uint256 paid = 0;
        uint256 sumShares = 0;
        for (uint256 i = 0; i < _referrers.length; i++) {
            uint256 referralAmount = (_amount * _referrers[i].share) / 10000;
            sumShares += _referrers[i].share;
            if (referralAmount > 0) {
                payable(_referrers[i].referrer).transfer(referralAmount);
                paid += referralAmount;
            }
        }
        require(sumShares < maxReferralShare, "TOO_HIGH_REFERRER_PCT");
        return paid;
    }

    //TODO: implement multi-currency
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
    }

    function cancelListing(uint256 _listingId) external {
        Listing storage listing = listings[_listingId];
        require(listing.seller == _msgSender(), "NOT_AUTHORIZED");
        delete listings[_listingId];
    }

    function buyListing(
        uint256 _listingId,
        Referrer[] calldata _referrers
    ) external {
        Listing memory listing = listings[_listingId];
        require(listing.seller != address(0), "LISTING_NOT_EXISTS");
        Currency memory currency = currencies[listing.currency];
        (
            address decodedCurrencyContract,
            uint256 decodedCurrencyTokenId
        ) = decodeCurrencyData(currency);
        require(currency.enabled == true, "CURRENCY_DISABLED");
        delete listings[_listingId];
        transfer(
            listing.asset.assetContract,
            listing.asset.tokenId,
            listing.seller,
            _msgSender(),
            1,
            TokenType.ERC721
        );
        uint256 paidRoyalties = payAssetRoyalties(
            listing.asset.assetContract,
            listing.asset.tokenId,
            listing.amount
        );
        uint256 platformFeesForListing = (listing.amount * platformFees) /
            10000;
        if (platformFeesForListing > 0) {
            if (_referrers.length > 0) {
                uint256 paidReferralFees = payReferrers(
                    listing.amount,
                    _referrers
                );
                transfer(
                    decodedCurrencyContract,
                    decodedCurrencyTokenId,
                    _msgSender(),
                    treasury,
                    platformFees - paidReferralFees,
                    currency.currencyType
                );
            } else {
                transfer(
                    decodedCurrencyContract,
                    decodedCurrencyTokenId,
                    _msgSender(),
                    treasury,
                    platformFees,
                    currency.currencyType
                );
            }
        }

        uint256 sellerAmount = listing.amount - platformFees - paidRoyalties;
        if (sellerAmount > 0) {
            transfer(
                decodedCurrencyContract,
                decodedCurrencyTokenId,
                _msgSender(),
                listing.seller,
                sellerAmount,
                currency.currencyType
            );
        }
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
            assets: _assetList,
            buyer: _msgSender(),
            amount: _amount,
            currency: _currency
        });
        offerSequence++;
    }

    function cancelOffer(uint256 _offerId) external {
        Offer memory storedOffer = offers[_offerId];
        require(storedOffer.buyer == _msgSender(), "NOT_AUTHORIZED");
        delete offers[_offerId];
        if (currencies[storedOffer.currency].currencyType == TokenType.ETH) {
            payable(storedOffer.buyer).transfer(storedOffer.amount);
        }
    }

    function acceptOffer(
        uint256 _offerId,
        address _assetContract,
        uint256 _tokenId,
        Referrer[] calldata _referrers
    ) external {
        Offer memory storedOffer = offers[_offerId];
        require(storedOffer.buyer == _msgSender(), "NOT_AUTHORIZED");
        bool assetFound = false;
        for (uint256 i = 0; i < storedOffer.assets.length; i++) {
            if (
                storedOffer.assets[i].assetContract == _assetContract &&
                storedOffer.assets[i].tokenId == _tokenId
            ) {
                assetFound = true;
            }
        }
        require(assetFound, "INVALID_ASSET");
        delete offers[_offerId];
        Currency memory currency = currencies[storedOffer.currency];
        require(currency.enabled == true, "CURRENCY_DISABLED");
        (
            address decodedCurrencyContract,
            uint256 decodedCurrencyTokenId
        ) = decodeCurrencyData(currency);
        transfer(
            _assetContract,
            _tokenId,
            _msgSender(),
            storedOffer.buyer,
            1,
            TokenType.ERC721
        );
        uint256 paidRoyalties = payAssetRoyalties(
            _assetContract,
            _tokenId,
            storedOffer.amount
        );
        uint256 platformFeesForListing = (storedOffer.amount * platformFees) /
            10000;
        if (platformFeesForListing > 0) {
            if (_referrers.length > 0) {
                uint256 paidReferralFees = payReferrers(
                    storedOffer.amount,
                    _referrers
                );
                transfer(
                    decodedCurrencyContract,
                    decodedCurrencyTokenId,
                    storedOffer.buyer,
                    treasury,
                    platformFees - paidReferralFees,
                    currency.currencyType
                );
            } else {
                transfer(
                    decodedCurrencyContract,
                    decodedCurrencyTokenId,
                    storedOffer.buyer,
                    treasury,
                    platformFees,
                    currency.currencyType
                );
            }
        }

        uint256 sellerAmount = storedOffer.amount -
            platformFees -
            paidRoyalties;
        if (sellerAmount > 0) {
            transfer(
                decodedCurrencyContract,
                decodedCurrencyTokenId,
                storedOffer.buyer,
                _msgSender(),
                sellerAmount,
                currency.currencyType
            );
        }
    }
}
