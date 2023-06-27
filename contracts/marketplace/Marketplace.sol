// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "contracts/abstract/admin/AuthorizedCaller.sol";

contract Marketplace is AuthorizedCaller {
    enum CurrencyType {
        ETH,
        ERC20,
        ERC1155
    }

    struct Referrer {
        address referrer;
        uint256 share;
    }

    struct Currency {
        CurrencyType currencyType;
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

    function transferToken(
        address _contract,
        address _owner,
        address _receiver,
        uint256 _tokenId
    ) private {
        IERC721(_contract).safeTransferFrom(_owner, _receiver, _tokenId);
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
        delete listings[_listingId];
        transferToken(
            listing.asset.assetContract,
            listing.seller,
            _msgSender(),
            listing.asset.tokenId
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
                payable(treasury).transfer(platformFees - paidReferralFees);
            } else {
                payable(treasury).transfer(platformFees);
            }
        }

        uint256 sellerAmount = listing.amount - platformFees - paidRoyalties;
        if (sellerAmount > 0) {
            payable(listing.seller).transfer(sellerAmount);
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
        if (storedCurrency.currencyType == CurrencyType.ETH) {
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
        if (currencies[storedOffer.currency].currencyType == CurrencyType.ETH) {
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
        transferToken(
            _assetContract,
            _msgSender(),
            storedOffer.buyer,
            _tokenId
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
                payable(treasury).transfer(platformFees - paidReferralFees);
            } else {
                payable(treasury).transfer(platformFees);
            }
        }

        uint256 sellerAmount = storedOffer.amount -
            platformFees -
            paidRoyalties;
        if (sellerAmount > 0) {
            payable(_msgSender()).transfer(sellerAmount);
        }
    }
}
