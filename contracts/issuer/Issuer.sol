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

import "contracts/abstract/AddressConfig.sol";
import "contracts/abstract/admin/AuthorizedCaller.sol";

import "contracts/libs/LibIssuer.sol";
import "contracts/libs/LibReserve.sol";

contract Issuer is IIssuer, IERC2981, AddressConfig, AuthorizedCaller {
    Config private config;
    uint256 private allissuers;
    uint256 private allGenTkTokens;
    mapping(uint256 => LibIssuer.IssuerData) private issuers;

    event IssuerMinted(MintIssuerInput params);
    event TokenMinted(MintInput params);
    event TokenMintedWithTicket(MintWithTicketInput params);
    event IssuerBurned(uint256 issuerId);
    event IssuerUpdated(UpdateIssuerInput params);
    event PriceUpdated(UpdatePriceInput params);
    event ReserveUpdated(UpdateReserveInput params);
    event SupplyBurned(uint256 issuerId, uint256 amount);
    event TokendModUpdated(uint256 issuerId, uint256[] tags);

    constructor(Config memory _config, address _admin) {
        config = _config;
        allissuers = 0;
        allGenTkTokens = 0;
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function mintIssuer(MintIssuerInput memory params) external {
        require(
            IAllowMintIssuer(addresses["al_mi"]).isAllowed(
                msg.sender,
                block.timestamp
            ),
            "403"
        );
        uint256 codexId = ICodex(addresses["codex"]).codexEntryIdFromInput(
            msg.sender,
            params.codex
        );
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

        require(issuers[allissuers].info.author == address(0), "409");

        IPricingManager(addresses["priceMag"]).verifyPricingMethod(
            params.pricing.pricingId
        );

        IPricing(
            IPricingManager(addresses["priceMag"])
                .getPricingContract(params.pricing.pricingId)
                .pricingContract
        ).setPrice(allissuers, params.pricing.details);

        bool hasTickets = params.mintTicketSettings.gracingPeriod > 0;
        if (hasTickets) {
            IMintTicket(addresses["mint_tickets"]).createProject(
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
            IModerationUser(addresses["user_mod"]).userState(msg.sender) == 10
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
                addresses["resMag"]
            ).getReserveMethod(params.reserves[i].methodId);
            require(
                reserveMethod.reserveContract != IReserve(address(0)),
                "NO_RESERVE_METHOD"
            );
            require(reserveMethod.enabled, "RESERVE_METHOD_DISABLED");
            reserveTotal += params.reserves[i].amount;
            require(
                IReserveManager(addresses["resMag"]).isReserveValid(
                    params.reserves[i]
                ),
                "WRG_RSRV"
            );
        }
        if (!isOpenEd) {
            require(reserveTotal <= params.amount, "RSRV_BIG");
        }

        issuers[allissuers] = LibIssuer.IssuerData({
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
                author: msg.sender,
                pricingId: params.pricing.pricingId,
                codexId: codexId,
                inputBytesSize: params.inputBytesSize
            })
        });

        IUserActions(addresses["userAct"]).setLastIssuerMinted(
            msg.sender,
            allissuers
        );

        allissuers++;
        emit IssuerMinted(params);
    }

    function mint(MintInput memory params) external payable {
        LibIssuer.IssuerData storage issuerToken = issuers[params.issuerId];

        require(issuerToken.info.author != address(0), "Token undefined");

        require(
            IAllowMint(addresses["al_m"]).isAllowed(
                msg.sender,
                block.timestamp,
                params.issuerId
            ),
            "403"
        );

        uint256 tokenId = allGenTkTokens;

        address recipient = msg.sender;
        if (params.recipient != address(0)) {
            recipient = params.recipient;
        }

        if (params.createTicket == true) {
            require(issuerToken.info.hasTickets, "ISSUER_NO_TICKETS");
        } else {
            require(
                params.inputBytes.length == issuerToken.info.inputBytesSize,
                "WRONG_INPUT_BYTES"
            );
        }

        require(
            SignedMath.abs(
                int256(block.timestamp) -
                    int256(issuerToken.info.timestampMinted)
            ) > issuerToken.info.lockedSeconds,
            "TOKEN_LOCKED"
        );
        require(
            issuerToken.info.enabled == true ||
                msg.sender == issuerToken.info.author,
            "TOKEN_DISABLED"
        );

        bool isOe = issuerToken.openEditions.closingTime > 0;
        if (isOe) {
            LibIssuer.OpenEditions memory oe = issuerToken.openEditions;
            if (oe.closingTime != 0) {
                require(block.timestamp < oe.closingTime, "OE_CLOSE");
            }
            issuerToken.supply += 1;
        } else {
            require(issuerToken.balance > 0, "NO_BLNCE");
            issuerToken.balance -= 1;
        }

        LibReserve.ReserveInput memory reserveInput;
        if (params.reserveInput.length > 0) {
            reserveInput = abi.decode(
                params.reserveInput,
                (LibReserve.ReserveInput)
            );
        }

        IPricing pricingContract = IPricing(
            IPricingManager(addresses["priceMag"])
                .getPricingContract(issuerToken.info.pricingId)
                .pricingContract
        );

        bool reserveApplied = false;
        uint256 reserveTotal = 0;
        {
            LibReserve.ReserveData[] memory decodedReserves = abi.decode(
                issuerToken.reserves,
                (LibReserve.ReserveData[])
            );
            for (uint256 i = 0; i < decodedReserves.length; i++) {
                reserveTotal += decodedReserves[i].amount;
                if (
                    reserveInput.methodId == decodedReserves[i].methodId &&
                    !reserveApplied
                ) {
                    (bool applied, bytes memory applyData) = IReserveManager(
                        addresses["resMag"]
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
                uint256 balanceWithoutReserve = issuerToken.balance -
                    reserveTotal;
                if ((balanceWithoutReserve <= 0) && (!reserveApplied)) {
                    require(
                        !((balanceWithoutReserve <= 0) && (!reserveApplied)),
                        "ONLY_RSRV"
                    );
                }
                if (
                    issuerToken.info.lockPriceForReserves &&
                    balanceWithoutReserve == 1 &&
                    !reserveApplied
                ) {
                    pricingContract.lockPrice(params.issuerId);
                }
            }
        }

        processTransfers(
            pricingContract,
            params,
            issuerToken,
            tokenId,
            recipient
        );

        IUserActions(addresses["userAct"]).setLastMinted(msg.sender, tokenId);
        emit TokenMinted(params);
    }

    function mintWithTicket(MintWithTicketInput memory params) external {
        LibIssuer.IssuerData storage issuerToken = issuers[params.issuerId];
        require(issuerToken.info.author != address(0), "Token undefined");
        require(
            params.inputBytes.length == issuerToken.info.inputBytesSize,
            "WRONG_INPUT_BYTES"
        );

        address recipient = msg.sender;
        if (params.recipient != address(0)) {
            recipient = params.recipient;
        }
        IMintTicket(addresses["mint_tickets"]).consume(
            msg.sender,
            params.ticketId,
            params.issuerId
        );

        issuerToken.iterationsCount += 1;

        IGenTk(addresses["gentk"]).mint(
            IGenTk.TokenParams({
                tokenId: allGenTkTokens,
                iteration: issuerToken.iterationsCount,
                inputBytes: params.inputBytes,
                receiver: issuerToken.royaltiesSplit.receiver ==
                    addresses["gentk"]
                    ? recipient
                    : issuerToken.royaltiesSplit.receiver,
                metadata: config.voidMetadata,
                issuerId: params.issuerId
            })
        );

        allGenTkTokens++;

        IUserActions(addresses["userAct"]).setLastMinted(
            msg.sender,
            params.issuerId
        );
        emit TokenMintedWithTicket(params);
    }

    function updateIssuer(UpdateIssuerInput calldata params) external {
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

        LibIssuer.IssuerData storage issuerToken = issuers[params.issuerId];
        verifyAuthorized(issuerToken.info.author);
        LibIssuer.verifyIssuerUpdateable(issuerToken);
        issuerToken.primarySplit = params.primarySplit;
        issuerToken.royaltiesSplit = params.royaltiesSplit;
        issuerToken.info.enabled = params.enabled;
        emit IssuerUpdated(params);
    }

    function updatePrice(UpdatePriceInput calldata params) external {
        LibIssuer.IssuerData storage issuerToken = issuers[params.issuerId];
        verifyAuthorized(issuerToken.info.author);
        LibIssuer.verifyIssuerUpdateable(issuerToken);
        IPricingManager(addresses["priceMag"]).verifyPricingMethod(
            params.pricingData.pricingId
        );
        issuerToken.info.pricingId = params.pricingData.pricingId;
        issuerToken.info.lockPriceForReserves = params
            .pricingData
            .lockForReserves;
        IPricing(
            IPricingManager(addresses["priceMag"])
                .getPricingContract(params.pricingData.pricingId)
                .pricingContract
        ).setPrice(params.issuerId, params.pricingData.details);
        emit PriceUpdated(params);
    }

    function updateReserve(UpdateReserveInput memory params) external {
        LibIssuer.IssuerData storage issuerToken = issuers[params.issuerId];
        verifyAuthorized(issuerToken.info.author);
        LibIssuer.verifyIssuerUpdateable(issuerToken);
        require(issuerToken.info.enabled, "TOK_DISABLED");
        for (uint256 i = 0; i < params.reserves.length; i++) {
            LibReserve.ReserveMethod memory reserve = IReserveManager(
                addresses["resMag"]
            ).getReserveMethod(params.reserves[i].methodId);
            require(
                reserve.reserveContract != IReserve(address(0)),
                "RSRV_404"
            );
            require(reserve.enabled, "RSRV_DIS");
            require(
                IReserveManager(addresses["resMag"]).isReserveValid(
                    params.reserves[i]
                )
            );
        }
        issuers[params.issuerId].reserves = abi.encode(params.reserves);
        emit ReserveUpdated(params);
    }

    function burn(uint256 issuerId) external {
        LibIssuer.IssuerData storage issuerToken = issuers[issuerId];
        verifyAuthorized(issuerToken.info.author);
        require(issuerToken.balance == issuerToken.supply, "CONSUMED_1");
        burnToken(issuerId);
        emit IssuerBurned(issuerId);
    }

    function burnSupply(uint256 issuerId, uint256 amount) external {
        require(amount > 0, "TOO_LOW");
        LibIssuer.IssuerData storage issuerToken = issuers[issuerId];
        verifyAuthorized(issuerToken.info.author);
        require(issuerToken.openEditions.closingTime == 0, "OES");
        require(amount <= issuerToken.balance, "TOO_HIGH");
        issuerToken.balance = issuerToken.balance - amount;
        issuerToken.supply = issuerToken.supply - amount;
        if (issuerToken.supply == 0) {
            burnToken(issuerId);
        }
        emit SupplyBurned(issuerId, amount);
    }

    function updateTokenMod(uint256 issuerId, uint256[] calldata tags)
        external
    {
        require(
            IModeration(addresses["mod_team"]).isAuthorized(msg.sender, 10),
            "403"
        );
        issuers[issuerId].info.tags = tags;
        emit TokendModUpdated(issuerId, tags);
    }

    function setCodex(uint256 issuerId, uint256 codexId)
        external
        onlyAuthorizedCaller
    {
        issuers[issuerId].info.codexId = codexId;
    }

    function setConfig(Config calldata _config) external onlyAdmin {
        config = _config;
    }

    function getIssuer(uint256 issuerId)
        external
        view
        returns (LibIssuer.IssuerData memory)
    {
        return issuers[issuerId];
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        public
        view
        override(IERC2981, IIssuer)
        returns (address receiver, uint256 royaltyAmount)
    {
        LibRoyalty.RoyaltyData memory royalty = issuers[tokenId].royaltiesSplit;
        uint256 amount = (salePrice * royalty.percent) / 10000;
        return (royalty.receiver, amount);
    }

    function primarySplitInfo(uint256 tokenId, uint256 salePrice)
        public
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        LibRoyalty.RoyaltyData memory royalty = issuers[tokenId].primarySplit;
        uint256 amount = (salePrice * royalty.percent) / 10000;
        return (royalty.receiver, amount);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl, IERC165, IIssuer)
        returns (bool)
    {
        return
            interfaceId == type(IIssuer).interfaceId ||
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function burnToken(uint256 issuerId) private {
        IUserActions(addresses["userAct"]).resetLastIssuerMinted(
            msg.sender,
            issuerId
        );
        delete issuers[issuerId];
    }

    function verifyAuthorized(address _author) private view {
        require(_author != address(0), "404");
        require(_author == msg.sender, "403");
    }

    function processTransfers(
        IPricing pricingContract,
        MintInput memory params,
        LibIssuer.IssuerData storage issuerToken,
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
                params.referrer != address(0) && params.referrer != msg.sender
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
                payable(addresses["treasury"]).transfer(feesAmount);
            }

            uint256 creatorAmount = price - (msg.value - feesAmount);
            uint256 splitAmount = (creatorAmount *
                issuerToken.primarySplit.percent) / 10000;
            if (splitAmount > 0) {
                payable(issuerToken.primarySplit.receiver).transfer(
                    splitAmount
                );
            }

            if (msg.value > price) {
                uint256 remainingAmount = msg.value - price;
                if (remainingAmount > 0) {
                    payable(msg.sender).transfer(remainingAmount);
                }
            }

            if (params.createTicket == true) {
                IMintTicket(addresses["mint_tickets"]).mint(
                    params.issuerId,
                    recipient,
                    price
                );
            } else {
                issuerToken.iterationsCount += 1;
                if (
                    issuerToken.royaltiesSplit.receiver == addresses["gentk"]
                ) {}

                IGenTk(addresses["gentk"]).mint(
                    IGenTk.TokenParams({
                        tokenId: tokenId,
                        iteration: issuerToken.iterationsCount,
                        inputBytes: params.inputBytes,
                        receiver: issuerToken.royaltiesSplit.receiver ==
                            addresses["gentk"]
                            ? recipient
                            : issuerToken.royaltiesSplit.receiver,
                        metadata: config.voidMetadata,
                        issuerId: params.issuerId
                    })
                );
                allGenTkTokens++;
            }
        }
    }
}
