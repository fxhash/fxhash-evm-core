// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";

import "contracts/interfaces/IIssuerToken.sol";
import "contracts/interfaces/IMintTicket.sol";
import "contracts/interfaces/IReserve.sol";
import "contracts/interfaces/IReserveManager.sol";
import "contracts/interfaces/IPricing.sol";
import "contracts/interfaces/IPricingManager.sol";
import "contracts/interfaces/IAllowMintIssuer.sol";
import "contracts/interfaces/IAllowMint.sol";
import "contracts/interfaces/IModeration.sol";
import "contracts/interfaces/IModerationUser.sol";
import "contracts/interfaces/IGenTk.sol";
import "contracts/interfaces/ICodex.sol";

import "contracts/abstract/admin/FxHashAdminVerify.sol";
import "contracts/abstract/AddressConfig.sol";
import "contracts/abstract/Treasury.sol";

import "contracts/libs/LibCodex.sol";
import "contracts/libs/LibIssuer.sol";
import "contracts/libs/LibReserve.sol";
import "contracts/libs/LibPricing.sol";

contract IssuerToken is
    IIssuerToken,
    FxHashAdminVerify,
    ERC721URIStorageUpgradeable,
    IERC2981Upgradeable,
    AddressConfig,
    Treasury
{
    struct MintTicketSettings {
        uint256 gracingPeriod; //in days
        string metadata;
    }

    struct MintIssuerInput {
        LibCodex.CodexInput codex;
        bytes metadata;
        uint256 inputBytesSize;
        uint256 amount;
        LibIssuer.OpenEditions openEditions;
        MintTicketSettings mintTicketSettings;
        LibReserve.ReserveData[] reserves;
        LibPricing.PricingData pricing;
        LibRoyalty.RoyaltyData primarySplit;
        LibRoyalty.RoyaltyData royaltiesSplit;
        bool enabled;
        uint256[] tags;
    }

    struct MintInput {
        uint256 issuerId;
        bytes inputBytes;
        address referrer;
        bytes reserveInput;
        bytes createTicket;
        address recipient;
    }

    struct MintWithTicketInput {
        uint256 issuerId;
        uint256 ticketId;
        bytes inputBytes;
        address recipient;
    }

    struct UpdateIssuerInput {
        uint256 issuerId;
        LibRoyalty.RoyaltyData primarySplit;
        LibRoyalty.RoyaltyData royaltiesSplit;
        bool enabled;
    }

    struct UpdatePriceInput {
        uint256 issuerId;
        LibPricing.PricingData pricingData;
    }

    struct UpdateReserveInput {
        uint256 issuerId;
        LibReserve.ReserveData[] reserves;
    }

    uint256 private fees;
    uint256 private referrerFees;
    uint256 private lockTime;
    string private voidMetadata;
    uint256 private allIssuerTokens;
    uint256 private allGenTkTokens;
    address private pricingManager;
    address private reserveManager;
    address private codex;
    mapping(uint256 => LibIssuer.IssuerTokenData) public issuerTokens;
    mapping(address => UserAction) public userActions;

    function initialize(
        uint256 _fees,
        address _pricingManager,
        address _reserveManager,
        address _codex
    ) external initializer {
        fees = _fees;
        allIssuerTokens = 0;
        allGenTkTokens = 0;
        pricingManager = _pricingManager;
        reserveManager = _reserveManager;
        codex = _codex;
        __ERC721_init("FxHashIssuer", "GTK");
        __ERC721URIStorage_init();
    }

    function setCodex(uint256 issuerId, uint256 codexId) external {
        issuerTokens[issuerId].info.codexId = codexId;
    }

    function setFees(uint256 _fees) external onlyFxHashAdmin {
        fees = _fees;
    }

    function setLockTime(uint256 _lockTime) external onlyFxHashAdmin {
        lockTime = _lockTime;
    }

    function setReferrerFees(uint256 _referrerFees) external onlyFxHashAdmin {
        referrerFees = _referrerFees;
    }

    function setVoidMetadata(
        string calldata _voidMetadata
    ) external onlyFxHashAdmin {
        voidMetadata = _voidMetadata;
    }

    function isTokenLocked(uint256 issuerId) public view returns (bool) {
        LibIssuer.IssuerTokenData storage issuerToken = issuerTokens[issuerId];
        int256 diff = int256(block.timestamp) -
            int256(issuerToken.info.timestampMinted);
        return SignedMath.abs(diff) < issuerToken.info.lockedSeconds;
    }

    function getTokenData(
        uint256 issuerId
    ) public view returns (LibIssuer.IssuerTokenData memory) {
        require(issuerTokens[issuerId].info.author != address(0), "NO_TOKEN");
        return issuerTokens[issuerId];
    }

    function getTokenPrimarySplit(
        uint256 issuerId
    ) public view returns (address receiver, uint256 royaltyAmount) {
        LibIssuer.IssuerTokenData storage issuerToken = issuerTokens[issuerId];
        require(issuerToken.info.author != address(0), "NO_TOKEN");
        return (
            issuerToken.primarySplit.receiver,
            issuerToken.primarySplit.percent
        );
    }

    function getUserActions(
        address user
    ) external view returns (UserAction memory) {
        return userActions[user];
    }

    function getIssuerPricingKt(
        uint256 issuerId
    ) private view returns (IPricing) {
        uint256 pricingId = issuerTokens[issuerId].info.pricingId;
        return
            IPricingManager(pricingManager)
                .getPricingContract(pricingId)
                .pricingContract;
    }

    function getTokenPrice(
        uint256 tokenId,
        uint256 timestamp
    ) external view returns (uint256) {
        IPricing pricingKt = getIssuerPricingKt(tokenId);
        return pricingKt.getPrice(tokenId, timestamp);
    }

    function mintIssuer(MintIssuerInput memory params) external {
        require(
            IAllowMintIssuer(addresses["al_mi"]).isAllowed(
                _msgSender(),
                block.timestamp
            ),
            "403"
        );
        uint256 codexId = ICodex(codex).codexEntryIdFromInput(
            _msgSender(),
            params.codex
        );
        uint256 _lockTime = lockTime;
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

        require(issuerTokens[allIssuerTokens].info.author == address(0), "409");

        IPricingManager(pricingManager).verifyPricingMethod(
            params.pricing.pricingId
        );

        IPricing(
            IPricingManager(pricingManager)
                .getPricingContract(params.pricing.pricingId)
                .pricingContract
        ).setPrice(allIssuerTokens, params.pricing.details);

        bool hasTickets = params.mintTicketSettings.gracingPeriod > 0;
        if (hasTickets) {
            IMintTicket(addresses["mint_tickets"]).createProject(
                allIssuerTokens,
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
            IModerationUser(addresses["user_mod"]).userState(_msgSender()) == 10
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
                reserveManager
            ).getReserveMethod(params.reserves[i].methodId);
            require(
                reserveMethod.reserveContract != IReserve(address(0)),
                "NO_RESERVE_METHOD"
            );
            require(reserveMethod.enabled, "RESERVE_METHOD_DISABLED");
            reserveTotal += params.reserves[i].amount;
            require(
                IReserveManager(reserveManager).isReserveValid(
                    params.reserves[i]
                ),
                "WRG_RSRV"
            );
        }
        if (!isOpenEd) {
            require(reserveTotal <= params.amount, "RSRV_BIG");
        }

        issuerTokens[allIssuerTokens] = LibIssuer.IssuerTokenData({
            metadata: params.metadata,
            balance: params.amount,
            iterationsCount: 0,
            supply: params.amount,
            openEditions: params.openEditions,
            reserves: params.reserves,
            primarySplit: params.primarySplit,
            royaltiesSplit: params.royaltiesSplit,
            info: LibIssuer.IssuerTokenInfo({
                tags: params.tags,
                enabled: params.enabled,
                lockedSeconds: _lockTime,
                timestampMinted: block.timestamp,
                lockPriceForReserves: params.pricing.lockForReserves,
                hasTickets: hasTickets,
                author: _msgSender(),
                pricingId: params.pricing.pricingId,
                codexId: codexId,
                inputBytesSize: params.inputBytesSize
            })
        });

        userActions[_msgSender()].lastIssuerMinted = allIssuerTokens;
        userActions[_msgSender()].lastIssuerMintedTime = block.timestamp;

        allIssuerTokens++;
    }

    function mint(MintInput memory params) external payable {
        LibIssuer.IssuerTokenData storage issuerToken = issuerTokens[
            params.issuerId
        ];

        require(issuerToken.info.author != address(0), "Token undefined");

        require(
            IAllowMint(addresses["al_m"]).isAllowed(
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

        if (params.createTicket.length != 0) {
            require(issuerToken.info.hasTickets, "ISSUER_NO_TICKETS");
        } else {
            require(
                params.inputBytes.length == issuerToken.info.inputBytesSize,
                "WRONG_INPUT_BYTES"
            );
        }

        require(isTokenLocked(params.issuerId) == false, "TOKEN_LOCKED");
        require(
            issuerToken.info.enabled == true ||
                _msgSender() == issuerToken.info.author,
            "TOKEN_DISABLED"
        );

        bool isOe = issuerToken.openEditions.closingTime > 0;
        if (isOe) {
            LibIssuer.OpenEditions memory oe = issuerToken.openEditions;
            if (oe.closingTime != 0) {
                require(block.timestamp < oe.closingTime, "OE_CLOSE");
            }
        } else {
            require(issuerToken.balance > 0, "NO_BLNCE");
        }

        LibReserve.ReserveInput memory reserveInput;
        if (params.reserveInput.length > 0) {
            reserveInput = abi.decode(
                params.reserveInput,
                (LibReserve.ReserveInput)
            );
        }

        IPricing pricingContract = IPricing(
            IPricingManager(pricingManager)
                .getPricingContract(issuerToken.info.pricingId)
                .pricingContract
        );

        bool reserveApplied = false;
        uint256 reserveTotal = 0;
        {
            for (uint256 i = 0; i < issuerToken.reserves.length; i++) {
                reserveTotal += issuerToken.reserves[i].amount;
                if (
                    reserveInput.methodId == issuerToken.reserves[i].methodId &&
                    !reserveApplied
                ) {
                    (bool applied, bytes memory applyData) = IReserveManager(
                        reserveManager
                    ).applyReserve(issuerToken.reserves[i], reserveInput.input);
                    if (applied) {
                        reserveApplied = true;
                        issuerToken.reserves[i].amount -= 1;
                        issuerToken.reserves[i].data = applyData;
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

        UserAction storage userAction = userActions[_msgSender()];
        if (userAction.lastMintedTime == block.timestamp) {
            userAction.lastMinted.push(tokenId);
        } else {
            userAction.lastMintedTime = block.timestamp;
            userAction.lastMinted = [tokenId];
        }
    }

    function mintWithTicket(MintWithTicketInput memory params) public {
        LibIssuer.IssuerTokenData storage issuerToken = issuerTokens[
            params.issuerId
        ];
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
            _msgSender(),
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
                metadata: voidMetadata,
                issuerId: params.issuerId
            })
        );

        allGenTkTokens++;

        UserAction storage userAction = userActions[msg.sender];
        if (userAction.lastMintedTime == block.timestamp) {
            userAction.lastMinted.push(params.issuerId);
        } else {
            userAction.lastMintedTime = block.timestamp;
            userAction.lastMinted = [params.issuerId];
        }
    }

    function processTransfers(
        IPricing pricingContract,
        MintInput memory params,
        LibIssuer.IssuerTokenData storage issuerToken,
        uint256 tokenId,
        address recipient
    ) private {
        {
            uint256 price = pricingContract.getPrice(
                params.issuerId,
                block.timestamp
            );
            require(msg.value >= price, "INVALID_PRICE");

            uint256 platformFees = fees;
            if (
                params.referrer != address(0) && params.referrer != _msgSender()
            ) {
                uint256 referrerShare = (fees * referrerFees) / 10000;
                uint256 referrerAmount = (price * referrerShare) / 10000;
                if (referrerAmount > 0) {
                    payable(params.referrer).transfer(referrerAmount);
                }
                platformFees = fees - referrerFees;
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

            if (params.createTicket.length != 0) {
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
                        metadata: voidMetadata,
                        issuerId: params.issuerId
                    })
                );
                allGenTkTokens++;
            }
        }
    }

    function burnToken(uint256 issuerId) private {
        UserAction storage action = userActions[_msgSender()];
        if (issuerId == action.lastIssuerMinted) {
            action.lastIssuerMintedTime = 0;
        }
        delete issuerTokens[issuerId];
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

        LibIssuer.IssuerTokenData storage issuerToken = issuerTokens[
            params.issuerId
        ];
        require(issuerToken.info.author != address(0), "404");
        require(issuerToken.info.author == _msgSender(), "403");
        LibIssuer.verifyIssuerUpdateable(issuerToken);
        issuerToken.primarySplit = params.primarySplit;
        issuerToken.royaltiesSplit = params.royaltiesSplit;
        issuerToken.info.enabled = params.enabled;
    }

    function updatePrice(UpdatePriceInput calldata params) external {
        LibIssuer.IssuerTokenData storage issuerToken = issuerTokens[
            params.issuerId
        ];
        require(issuerToken.info.author != address(0), "404");
        require(issuerToken.info.author == _msgSender(), "403");
        LibIssuer.verifyIssuerUpdateable(issuerToken);
        IPricingManager(pricingManager).verifyPricingMethod(
            params.pricingData.pricingId
        );
        issuerToken.info.pricingId = params.pricingData.pricingId;
        issuerToken.info.lockPriceForReserves = params
            .pricingData
            .lockForReserves;
        IPricing(
            IPricingManager(pricingManager)
                .getPricingContract(params.pricingData.pricingId)
                .pricingContract
        ).setPrice(params.issuerId, params.pricingData.details);
    }

    // function updateReserve(UpdateReserveInput memory params) external {
    //     LibIssuer.IssuerTokenData storage issuerToken = issuerTokens[
    //         params.issuerId
    //     ];
    //     require(issuerToken.info.author != address(0), "404");
    //     require(issuerToken.info.author == _msgSender(), "403");
    //     LibIssuer.verifyIssuerUpdateable(issuerToken);
    //     require(issuerToken.info.enabled, "TOK_DISABLED");
    //     for (uint256 i = 0; i < params.reserves.length; i++) {
    //         LibReserve.ReserveMethod memory reserve = IReserveManager(
    //             reserveManager
    //         ).getReserveMethod(params.reserves[i].methodId);
    //         require(
    //             reserve.reserveContract != IReserve(address(0)),
    //             "RSRV_404"
    //         );
    //         require(reserve.enabled, "RSRV_DIS");
    //         require(
    //             IReserveManager(reserveManager).isReserveValid(
    //                 params.reserves[i]
    //             )
    //         );
    //     }
    //     issuerTokens[params.issuerId].reserves = params.reserves;
    // }

    function burn(uint256 issuerId) external {
        LibIssuer.IssuerTokenData storage issuerToken = issuerTokens[issuerId];
        require(issuerToken.info.author != address(0), "404");
        require(issuerToken.info.author == _msgSender(), "403");
        require(issuerToken.balance == issuerToken.supply, "CONSUMED_1");
        burnToken(issuerId);
    }

    function burnSupply(uint256 issuerId, uint256 amount) external {
        require(amount > 0, "TOO_LOW");
        LibIssuer.IssuerTokenData storage issuerToken = issuerTokens[issuerId];
        require(issuerToken.info.author != address(0), "404");
        require(issuerToken.openEditions.closingTime == 0, "OES");
        require(issuerToken.info.author == _msgSender(), "403");
        require(amount <= issuerToken.balance, "TOO_HIGH");
        issuerToken.balance = issuerToken.balance - amount;
        issuerToken.supply = issuerToken.supply - amount;
        if (issuerToken.supply == 0) {
            burnToken(issuerId);
        }
    }

    function updateTokenMod(
        uint256 issuerId,
        uint256[] calldata tags
    ) external {
        require(
            IModeration(addresses["mod_team"]).isAuthorized(_msgSender(), 10),
            "403"
        );
        issuerTokens[issuerId].info.tags = tags;
    }

    function _msgSender()
        internal
        view
        virtual
        override(Context, ContextUpgradeable)
        returns (address)
    {
        return super._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override(Context, ContextUpgradeable)
        returns (bytes calldata)
    {
        return super._msgData();
    }

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    )
        public
        view
        override(IERC2981Upgradeable, IIssuerToken)
        returns (address receiver, uint256 royaltyAmount)
    {
        LibRoyalty.RoyaltyData memory royalty = issuerTokens[tokenId]
            .royaltiesSplit;
        uint256 amount = (salePrice * royalty.percent) / 10000;
        return (royalty.receiver, amount);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(AccessControl, ERC721URIStorageUpgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
