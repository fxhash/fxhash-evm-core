// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "contracts/interfaces/IMintTicket.sol";
import "contracts/interfaces/IReserveManager.sol";
import "contracts/interfaces/IPricingManager.sol";
import "contracts/interfaces/IAllowMintIssuer.sol";
import "contracts/interfaces/IAllowMint.sol";
import "contracts/interfaces/IModeration.sol";
import "contracts/interfaces/IModerationUser.sol";
import "contracts/interfaces/IGenTk.sol";
import "contracts/interfaces/ICodex.sol";
import "contracts/interfaces/IIssuer.sol";
import "contracts/interfaces/IUserActions.sol";
import "contracts/interfaces/IOnChainTokenMetadataManager.sol";

import "contracts/abstract/admin/AuthorizedCaller.sol";

import "contracts/libs/LibIssuer.sol";
import "contracts/libs/LibReserve.sol";

contract Issuer is IIssuer, IERC2981, AuthorizedCaller {
    Config private config;
    uint256 private allissuers;
    uint256 private allGenTkTokens;
    LibIssuer.IssuerData public issuer;

    event IssuerMinted(MintIssuerInput params);
    event TokenMinted(MintInput params);
    event TokenMintedWithTicket(MintWithTicketInput params);
    event IssuerBurned();
    event IssuerUpdated(UpdateIssuerInput params);
    event PriceUpdated(UpdatePriceInput params);
    event ReserveUpdated(UpdateReserveInput params);
    event SupplyBurned(uint256 amount);
    event TokendModUpdated(uint256[] tags);

    constructor(Config memory _config, address _admin, address _author) {
        config = _config;
        allissuers = 0;
        allGenTkTokens = 0;
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(LibIssuer.AUTHOR_ROLE, _author);
    }

    function mintIssuer(MintIssuerInput memory params) external {
        require(
            IAllowMintIssuer(config.contractRegistry.getContract("al_mi"))
                .isAllowed(_msgSender(), block.timestamp),
            "403"
        );
        uint256 codexId = ICodex(config.contractRegistry.getContract("codex"))
            .codexEntryIdFromInput(_msgSender(), params.codex);
        uint256 _lockTime = config.lockTime;
        require(
            ((params.royaltiesSplit.percent >= 1000) &&
                (params.royaltiesSplit.percent <= 2500)) ||
                ((!params.enabled) && (params.royaltiesSplit.percent <= 2500)),
            "WRG_ROY"
        );
        require(
            ((params.primarySplit.percent >= 1000) &&
                (params.primarySplit.percent <= 2500)),
            "WRG_PRIM_SPLIT"
        );

        require(issuer.supply == 0, "409");

        IPricingManager(config.contractRegistry.getContract("priceMag"))
            .verifyPricingMethod(params.pricing.pricingId);

        IPricing(
            IPricingManager(config.contractRegistry.getContract("priceMag"))
                .getPricingContract(params.pricing.pricingId)
                .pricingContract
        ).setPrice(allissuers, params.pricing.details);

        bool hasTickets = params.mintTicketSettings.gracingPeriod > 0;
        if (hasTickets) {
            IMintTicket(config.contractRegistry.getContract("mint_tickets"))
                .createProject(
                    allissuers,
                    params.mintTicketSettings.gracingPeriod,
                    params.mintTicketSettings.metadata
                );
        }

        //TODO: once we have the collaboration factory, we need to update that
        // if (isCollaborationContract(sp.sender)) {
        //     Set.SetAddress storage collaborators = getCollaborators(sp.sender);
        //     Set.SetElement[] memory collaborator_elements = collaborators
        //         .elements();
        //     bool all_verified = true;
        //     for (uint256 i = 0; i < collaborator_elements.length; i++) {
        //         if (
        //             getUserState(
        //                 getUserModAddress(),
        //                 collaborator_elements[i].value
        //             ) != 10
        //         ) {
        //             all_verified = false;
        //             break;
        //         }
        //     }
        //     if (all_verified) {
        //         lock_time = 0;
        //     }
        // } else {

        if (
            IModerationUser(config.contractRegistry.getContract("user_mod"))
                .userState(_msgSender()) == 10
        ) {
            _lockTime = 0;
        }
        //}
        bool isOpenEd = params.openEditions.closingTime > 0;
        if (isOpenEd) {
            require(
                block.timestamp + _lockTime < params.openEditions.closingTime,
                "OES_CLOSING"
            );
        } else {
            require(params.amount > 0, "!SPLY>0");
        }

        uint256 reserveTotal = 0;
        for (uint256 i = 0; i < params.reserves.length; i++) {
            LibReserve.ReserveMethod memory reserveMethod = IReserveManager(
                config.contractRegistry.getContract("resMag")
            ).getReserveMethod(params.reserves[i].methodId);
            require(
                reserveMethod.reserveContract != IReserve(address(0)),
                "NO_RESERVE_METHOD"
            );
            require(reserveMethod.enabled, "RESERVE_METHOD_DISABLED");
            reserveTotal += params.reserves[i].amount;
            require(
                IReserveManager(config.contractRegistry.getContract("resMag"))
                    .isReserveValid(params.reserves[i]),
                "WRG_RSRV"
            );
        }
        if (!isOpenEd) {
            require(reserveTotal <= params.amount, "RSRV_BIG");
        }

        issuer = LibIssuer.IssuerData({
            metadata: params.metadata,
            balance: params.amount,
            iterationsCount: 0,
            supply: params.amount,
            openEditions: params.openEditions,
            reserves: abi.encode(params.reserves),
            primarySplit: params.primarySplit,
            royaltiesSplit: params.royaltiesSplit,
            onChainData: abi.encode(params.onChainScripts),
            info: LibIssuer.IssuerInfo({
                tags: params.tags,
                enabled: params.enabled,
                lockedSeconds: _lockTime,
                timestampMinted: block.timestamp,
                lockPriceForReserves: params.pricing.lockForReserves,
                hasTickets: hasTickets,
                pricingId: params.pricing.pricingId,
                codexId: codexId,
                inputBytesSize: params.inputBytesSize
            })
        });

        IUserActions(config.contractRegistry.getContract("userAct"))
            .setLastIssuerMinted(_msgSender(), address(this));

        allissuers++;
        emit IssuerMinted(params);
    }

    function mint(MintInput memory params) external payable {
        require(issuer.supply > 0, "Token undefined");

        require(
            IAllowMint(config.contractRegistry.getContract("al_m")).isAllowed(
                _msgSender(),
                block.timestamp,
                params.issuerId
            ),
            "403"
        );

        uint256 tokenId = allGenTkTokens;

        address recipient = _msgSender();
        if (params.recipient != address(0)) {
            recipient = params.recipient;
        }

        if (params.createTicket == true) {
            require(issuer.info.hasTickets, "ISSUER_NO_TICKETS");
        } else {
            require(
                params.inputBytes.length == issuer.info.inputBytesSize,
                "WRONG_INPUT_BYTES"
            );
        }

        require(
            SignedMath.abs(
                int256(block.timestamp) - int256(issuer.info.timestampMinted)
            ) > issuer.info.lockedSeconds,
            "TOKEN_LOCKED"
        );
        require(
            issuer.info.enabled == true ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "TOKEN_DISABLED"
        );

        bool isOe = issuer.openEditions.closingTime > 0;
        if (isOe) {
            LibIssuer.OpenEditions memory oe = issuer.openEditions;
            if (oe.closingTime != 0) {
                require(block.timestamp < oe.closingTime, "OE_CLOSE");
            }
            issuer.supply += 1;
        } else {
            require(issuer.balance > 0, "NO_BLNCE");
            issuer.balance -= 1;
        }

        LibReserve.ReserveInput memory reserveInput;
        if (params.reserveInput.length > 0) {
            reserveInput = abi.decode(
                params.reserveInput,
                (LibReserve.ReserveInput)
            );
        }

        IPricing pricingContract = IPricing(
            IPricingManager(config.contractRegistry.getContract("priceMag"))
                .getPricingContract(issuer.info.pricingId)
                .pricingContract
        );

        bool reserveApplied = false;
        uint256 reserveTotal = 0;
        {
            LibReserve.ReserveData[] memory decodedReserves = abi.decode(
                issuer.reserves,
                (LibReserve.ReserveData[])
            );
            for (uint256 i = 0; i < decodedReserves.length; i++) {
                reserveTotal += decodedReserves[i].amount;
                if (
                    reserveInput.methodId == decodedReserves[i].methodId &&
                    !reserveApplied
                ) {
                    (bool applied, bytes memory applyData) = IReserveManager(
                        config.contractRegistry.getContract("resMag")
                    ).applyReserve(decodedReserves[i], reserveInput.input);
                    if (applied) {
                        reserveApplied = true;
                        decodedReserves[i].amount -= 1;
                        decodedReserves[i].data = applyData;
                    }
                }
            }

            if (isOe) {
                if (reserveTotal > 0) {
                    require(reserveApplied, "ONLY_RSRV");
                }
            } else {
                uint256 balanceWithoutReserve = issuer.balance - reserveTotal;
                if ((balanceWithoutReserve <= 0) && (!reserveApplied)) {
                    require(
                        !((balanceWithoutReserve <= 0) && (!reserveApplied)),
                        "ONLY_RSRV"
                    );
                }
                if (
                    issuer.info.lockPriceForReserves &&
                    balanceWithoutReserve == 1 &&
                    !reserveApplied
                ) {
                    pricingContract.lockPrice(params.issuerId);
                }
            }
        }

        processTransfers(pricingContract, params, tokenId, recipient);

        IUserActions(config.contractRegistry.getContract("userAct"))
            .setLastMinted(_msgSender(), address(this), tokenId);
        emit TokenMinted(params);
    }

    function mintWithTicket(MintWithTicketInput memory params) external {
        require(
            params.inputBytes.length == issuer.info.inputBytesSize,
            "WRONG_INPUT_BYTES"
        );

        address recipient = msg.sender;
        if (params.recipient != address(0)) {
            recipient = params.recipient;
        }
        IMintTicket(config.contractRegistry.getContract("mint_tickets"))
            .consume(_msgSender(), params.ticketId, params.issuerId);

        issuer.iterationsCount += 1;
        address gentkContract = config.contractRegistry.getContract("gentk");
        IGenTk(gentkContract).mint(
            IGenTk.TokenParams({
                tokenId: allGenTkTokens,
                iteration: issuer.iterationsCount,
                inputBytes: params.inputBytes,
                receiver: issuer.royaltiesSplit.receiver == gentkContract
                    ? recipient
                    : issuer.royaltiesSplit.receiver,
                metadata: config.voidMetadata,
                issuerId: params.issuerId
            })
        );

        IUserActions(config.contractRegistry.getContract("userAct"))
            .setLastMinted(_msgSender(), address(this), allGenTkTokens);
        allGenTkTokens++;

        emit TokenMintedWithTicket(params);
    }

    function updateIssuer(
        UpdateIssuerInput calldata params
    ) external onlyRole(LibIssuer.AUTHOR_ROLE) {
        require(
            ((params.royaltiesSplit.percent >= 1000) &&
                (params.royaltiesSplit.percent <= 2500)) ||
                ((!params.enabled) && (params.royaltiesSplit.percent <= 2500)),
            "WRG_ROY"
        );
        require(
            ((params.primarySplit.percent >= 1000) &&
                (params.primarySplit.percent <= 2500)),
            "WRG_PRIM_SPLIT"
        );

        LibIssuer.verifyIssuerUpdateable(issuer);
        issuer.primarySplit = params.primarySplit;
        issuer.royaltiesSplit = params.royaltiesSplit;
        issuer.info.enabled = params.enabled;
        emit IssuerUpdated(params);
    }

    function updatePrice(
        UpdatePriceInput calldata params
    ) external onlyRole(LibIssuer.AUTHOR_ROLE) {
        LibIssuer.verifyIssuerUpdateable(issuer);
        IPricingManager(config.contractRegistry.getContract("priceMag"))
            .verifyPricingMethod(params.pricingData.pricingId);
        issuer.info.pricingId = params.pricingData.pricingId;
        issuer.info.lockPriceForReserves = params.pricingData.lockForReserves;
        IPricing(
            IPricingManager(config.contractRegistry.getContract("priceMag"))
                .getPricingContract(params.pricingData.pricingId)
                .pricingContract
        ).setPrice(params.issuerId, params.pricingData.details);
        emit PriceUpdated(params);
    }

    function updateReserve(
        UpdateReserveInput memory params
    ) external onlyRole(LibIssuer.AUTHOR_ROLE) {
        LibIssuer.verifyIssuerUpdateable(issuer);
        require(issuer.info.enabled, "TOK_DISABLED");
        for (uint256 i = 0; i < params.reserves.length; i++) {
            LibReserve.ReserveMethod memory reserve = IReserveManager(
                config.contractRegistry.getContract("resMag")
            ).getReserveMethod(params.reserves[i].methodId);
            require(
                reserve.reserveContract != IReserve(address(0)),
                "RSRV_404"
            );
            require(reserve.enabled, "RSRV_DIS");
            require(
                IReserveManager(config.contractRegistry.getContract("resMag"))
                    .isReserveValid(params.reserves[i])
            );
        }
        issuer.reserves = abi.encode(params.reserves);
        emit ReserveUpdated(params);
    }

    function burn() external onlyRole(LibIssuer.AUTHOR_ROLE) {
        require(issuer.balance == issuer.supply, "CONSUMED_1");
        burnToken();
        emit IssuerBurned();
    }

    function burnSupply(
        uint256 amount
    ) external onlyRole(LibIssuer.AUTHOR_ROLE) {
        require(amount > 0, "TOO_LOW");
        require(issuer.openEditions.closingTime == 0, "OES");
        require(amount <= issuer.balance, "TOO_HIGH");
        issuer.balance = issuer.balance - amount;
        issuer.supply = issuer.supply - amount;
        if (issuer.supply == 0) {
            burnToken();
        }
        emit SupplyBurned(amount);
    }

    function updateTokenMod(uint256[] calldata tags) external {
        require(
            IModeration(config.contractRegistry.getContract("mod_team"))
                .isAuthorized(_msgSender(), 10),
            "403"
        );
        issuer.info.tags = tags;
        emit TokendModUpdated(tags);
    }

    function setCodex(uint256 codexId) external onlyAuthorizedCaller {
        issuer.info.codexId = codexId;
    }

    function setConfig(Config calldata _config) external onlyAuthorizedCaller {
        config = _config;
    }

    function getIssuer() external view returns (LibIssuer.IssuerData memory) {
        return issuer;
    }

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    )
        public
        view
        override(IERC2981, IIssuer)
        returns (address receiver, uint256 royaltyAmount)
    {
        LibRoyalty.RoyaltyData memory royalty = issuer.royaltiesSplit;
        uint256 amount = (salePrice * royalty.percent) / 10000;
        return (royalty.receiver, amount);
    }

    function primarySplitInfo(
        uint256 salePrice
    ) public view returns (address receiver, uint256 royaltyAmount) {
        LibRoyalty.RoyaltyData memory royalty = issuer.primarySplit;
        uint256 amount = (salePrice * royalty.percent) / 10000;
        return (royalty.receiver, amount);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl, IERC165, IIssuer) returns (bool) {
        return
            interfaceId == type(IIssuer).interfaceId ||
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function burnToken() private {
        IUserActions(config.contractRegistry.getContract("userAct"))
            .resetLastIssuerMinted(_msgSender(), address(this));
        delete issuer;
    }

    function isAuthor(address _author) external view returns (bool) {
        return hasRole(LibIssuer.AUTHOR_ROLE, _author);
    }

    function processTransfers(
        IPricing pricingContract,
        MintInput memory params,
        uint256 tokenId,
        address recipient
    ) private {
        {
            uint256 price = pricingContract.getPrice(
                params.issuerId,
                block.timestamp
            );
            require(msg.value >= price, "INVALID_PRICE");

            uint256 platformFees = config.fees;
            if (
                params.referrer != address(0) && params.referrer != _msgSender()
            ) {
                uint256 referrerFees = (config.fees *
                    config.referrerFeesShare) / 10000;
                uint256 referrerAmount = (price * referrerFees) / 10000;
                if (referrerAmount > 0) {
                    payable(params.referrer).transfer(referrerAmount);
                }
                platformFees = config.fees - referrerFees;
            }

            uint256 feesAmount = (price * platformFees) / 10000;
            if (feesAmount > 0) {
                payable(config.contractRegistry.getContract("treasury"))
                    .transfer(feesAmount);
            }

            uint256 creatorAmount = price - (msg.value - feesAmount);
            uint256 splitAmount = (creatorAmount *
                issuer.primarySplit.percent) / 10000;
            if (splitAmount > 0) {
                payable(issuer.primarySplit.receiver).transfer(splitAmount);
            }

            if (msg.value > price) {
                uint256 remainingAmount = msg.value - price;
                if (remainingAmount > 0) {
                    payable(msg.sender).transfer(remainingAmount);
                }
            }

            if (params.createTicket == true) {
                IMintTicket(config.contractRegistry.getContract("mint_tickets"))
                    .mint(params.issuerId, recipient, price);
            } else {
                issuer.iterationsCount += 1;
                address gentkContract = config.contractRegistry.getContract(
                    "gentk"
                );
                IGenTk(gentkContract).mint(
                    IGenTk.TokenParams({
                        tokenId: tokenId,
                        iteration: issuer.iterationsCount,
                        inputBytes: params.inputBytes,
                        receiver: issuer.royaltiesSplit.receiver ==
                            gentkContract
                            ? recipient
                            : issuer.royaltiesSplit.receiver,
                        metadata: config.voidMetadata,
                        issuerId: params.issuerId
                    })
                );
                allGenTkTokens++;
            }
        }
    }
}
