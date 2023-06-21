// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "contracts/interfaces/IFxHashIssuer.sol";
import "contracts/interfaces/IMintTicket.sol";
import "contracts/interfaces/IReserve.sol";
import "contracts/interfaces/IPricing.sol";
import "contracts/interfaces/IAllowMintIssuer.sol";
import "contracts/interfaces/IAllowMint.sol";
import "contracts/interfaces/IModeration.sol";
import "contracts/interfaces/IModerationUser.sol";
import "contracts/interfaces/IGenTk.sol";
import "contracts/abstract/admin/FxHashAdminVerify.sol";
import "contracts/abstract/AddressConfig.sol";
import "contracts/abstract/Treasury.sol";

contract FxHashIssuer is
    IFxHashIssuer,
    FxHashAdminVerify,
    ERC721URIStorageUpgradeable,
    IERC2981Upgradeable,
    AddressConfig,
    Treasury
{
    struct ReserveData {
        uint256 methodId;
        uint256 amount;
        bytes data;
    }

    struct ReserveInput {
        uint256 methodId;
        bytes input;
    }

    struct ReserveMethod {
        IReserve reserveContract;
        bool enabled;
    }

    struct OpenEditions {
        uint256 closingTime;
        bytes extra;
    }

    struct RoyaltyData {
        uint256 percent;
        address receiver;
    }

    struct IssuerTokenData {
        address author;
        uint256 balance;
        uint256 iterationsCount;
        uint256 codexId;
        bytes metadata;
        uint256 inputBytesSize;
        uint256 supply;
        OpenEditions openEditions;
        bool hasTickets;
        ReserveData[] reserves;
        uint256 pricingId;
        bool lockPriceForReserves;
        RoyaltyData primarySplit;
        RoyaltyData royaltiesSplit;
        bool enabled;
        uint256 timestampMinted;
        uint256 lockedSeconds;
        uint256[] tags;
    }

    struct PricingContract {
        IPricing pricingContract;
        bool enabled;
    }

    struct CodexData {
        uint256 entryType;
        address author;
        bool locked;
        bytes[] value;
    }

    struct CodexInput {
        uint256 inputType;
        bytes value;
        uint256 codexId;
    }

    struct MintTicketSettings {
        uint256 gracingPeriod; //in days
        string metadata;
    }

    struct PricingData {
        uint256 pricingId;
        bytes details;
        bool lockForReserves;
    }

    struct MintIssuerInput {
        CodexInput codex;
        bytes metadata;
        uint256 inputBytesSize;
        uint256 amount;
        OpenEditions openEditions;
        MintTicketSettings mintTicketSettings;
        ReserveData[] reserves;
        PricingData pricing;
        RoyaltyData primarySplit;
        RoyaltyData royaltiesSplit;
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
        RoyaltyData primarySplit;
        RoyaltyData royaltiesSplit;
        bool enabled;
    }

    struct UpdatePriceInput {
        uint256 issuerId;
        PricingData pricingData;
    }

    struct UpdateReserveInput {
        uint256 issuerId;
        ReserveData[] reserves;
    }

    uint256 public fees;
    uint256 public referrerFees;
    uint256 public lockTime;
    string public voidMetadata;
    uint256 public codexEntriesCount;
    uint256 public allIssuerTokens;
    uint256 public allGenTkTokens;

    mapping(uint256 => ReserveMethod) public reserveMethods;
    mapping(uint256 => IssuerTokenData) public issuerTokens;
    mapping(address => UserAction) public userActions;
    mapping(uint256 => PricingContract) public pricingContracts;
    mapping(uint256 => CodexData) private codexEntries;
    mapping(uint256 => uint256) private issuerCodexUpdates;

    function initialize(uint256 _fees) external initializer {
        fees = _fees;

        __ERC721_init("FxHashIssuer", "GTK");
        __ERC721URIStorage_init();
    }

    function isReserveValid(
        ReserveData memory reserve
    ) public view returns (bool) {
        return
            reserveMethods[reserve.methodId].reserveContract.isInputValid(
                LibReserve.InputParams({
                    data: reserve.data,
                    amount: reserve.amount,
                    sender: _msgSender()
                })
            );
    }

    function applyReserve(
        ReserveData memory reserve,
        bytes memory userInput
    ) public returns (bool, bytes memory) {
        ReserveMethod storage method = reserveMethods[reserve.methodId];
        return
            method.reserveContract.applyReserve(
                LibReserve.ApplyParams({
                    currentData: reserve.data,
                    currentAmount: reserve.amount,
                    sender: _msgSender(),
                    userInput: userInput
                })
            );
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

    function setReserveMethod(
        uint256 id,
        ReserveMethod memory reserveMethod
    ) external onlyFxHashAdmin {
        reserveMethods[id] = reserveMethod;
    }

    function isTokenLocked(uint256 issuerId) public view returns (bool) {
        IssuerTokenData storage issuerToken = issuerTokens[issuerId];
        int256 diff = int256(block.timestamp) -
            int256(issuerToken.timestampMinted);
        return SignedMath.abs(diff) < issuerToken.lockedSeconds;
    }

    function getTokenData(
        uint256 issuerId
    ) public view returns (IssuerTokenData memory) {
        require(issuerTokens[issuerId].author != address(0), "NO_TOKEN");
        return issuerTokens[issuerId];
    }

    function getTokenPrimarySplit(
        uint256 issuerId
    ) public view returns (address receiver, uint256 royaltyAmount) {
        IssuerTokenData memory issuerToken = issuerTokens[issuerId];
        require(issuerToken.author != address(0), "NO_TOKEN");
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
        uint256 pricingId = issuerTokens[issuerId].pricingId;
        return pricingContracts[pricingId].pricingContract;
    }

    function getTokenPrice(
        uint256 tokenId,
        uint256 timestamp
    ) external view returns (uint256) {
        IPricing pricingKt = getIssuerPricingKt(tokenId);
        return pricingKt.getPrice(tokenId, timestamp);
    }

    function setPricingContract(
        uint256 id,
        address contractAddress,
        bool enabled
    ) public onlyFxHashAdmin {
        pricingContracts[id] = PricingContract({
            pricingContract: IPricing(contractAddress),
            enabled: enabled
        });
    }

    function codexInsert(
        uint256 entryType,
        address author,
        bool locked,
        bytes[] memory value
    ) private {
        codexEntries[codexEntriesCount] = CodexData(
            entryType,
            author,
            locked,
            value
        );
        codexEntriesCount++;
    }

    function codexEntryIdFromInput(
        address author,
        CodexInput memory input
    ) private returns (uint256) {
        uint256 codexIdValue = 0;
        if (input.codexId > 0) {
            require(
                codexEntries[input.codexId].author != address(0),
                "CDX_EMPTY"
            );
            require(codexEntries[input.codexId].locked, "CDX_NOT_LOCK");
            codexIdValue = input.codexId;
        } else {
            require(input.inputType > 0, "CDX_EMP");
            bytes[] memory valueBytes = new bytes[](1);
            valueBytes[0] = input.value;
            codexInsert(input.inputType, author, true, valueBytes);
            codexIdValue = codexEntriesCount - 1;
        }
        return codexIdValue;
    }

    function codexAddEntry(uint256 entryType, bytes[] memory value) public {
        codexInsert(entryType, _msgSender(), true, value);
    }

    function codexLockEntry(uint256 entryId) public {
        CodexData storage entry = codexEntries[entryId];
        require(entry.author == _msgSender(), "403");
        require(!entry.locked, "CDX_LOCK");
        require(entry.value.length > 0, "CDX_EMP");
        entry.locked = true;
    }

    function codexUpdateEntry(
        uint256 entryId,
        bool pushEnd,
        bytes memory value
    ) public {
        CodexData storage entry = codexEntries[entryId];
        require(entry.author == _msgSender(), "403");
        require(!entry.locked, "CDX_LOCK");
        if (pushEnd) {
            entry.value.push(value);
        } else {
            bytes[] memory valueBytes = new bytes[](1);
            valueBytes[0] = value;
            entry.value = valueBytes;
        }
    }

    function updateIssuerCodexRequest(
        uint256 _issuerId,
        CodexInput calldata input
    ) public {
        require(_issuerId > 0, "NO_ISSUER");
        IssuerTokenData memory issuer = issuerTokens[_issuerId];
        require(issuer.author == _msgSender(), "403");
        uint256 codexId = codexEntryIdFromInput(_msgSender(), input);
        require(issuerCodexUpdates[_issuerId] != codexId, "SAME_CDX_ID");
        issuerCodexUpdates[_issuerId] = codexId;
    }

    function updateIssuerCodexApprove(
        uint256 _issuerId,
        uint256 _codexId
    ) public {
        uint256 issuerId = issuerCodexUpdates[_issuerId];
        require(issuerId > 0, "NO_REQ");
        require(issuerId == _codexId, "WRG_CDX_ID");
        require(
            IModeration(addresses["mod_team"]).isAuthorized(msg.sender, 701),
            "403"
        );
        issuerTokens[_issuerId].codexId = issuerId;
        delete issuerCodexUpdates[issuerId];
    }

    function verifyPricingMethod(uint256 pricingId) private view {
        require(
            address(pricingContracts[pricingId].pricingContract) != address(0),
            "PRC_MTD_NOT"
        );
        require(pricingContracts[pricingId].enabled == true, "PRC_MTD_DIS");
    }

    function mintIssuer(MintIssuerInput memory params) external {
        require(
            IAllowMintIssuer(addresses["al_mi"]).isAllowed(
                _msgSender(),
                block.timestamp
            ),
            "403"
        );
        uint256 codexId = codexEntryIdFromInput(_msgSender(), params.codex);
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

        require(issuerTokens[allIssuerTokens].author == address(0), "409");

        verifyPricingMethod(params.pricing.pricingId);

        IPricing(pricingContracts[params.pricing.pricingId].pricingContract)
            .setPrice(allIssuerTokens, params.pricing.details);

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
            require(
                reserveMethods[params.reserves[i].methodId].reserveContract !=
                    IReserve(address(0)),
                "NO_RESERVE_METHOD"
            );
            require(
                reserveMethods[params.reserves[i].methodId].enabled,
                "RESERVE_METHOD_DISABLED"
            );
            reserveTotal += params.reserves[i].amount;
            require(isReserveValid(params.reserves[i]), "WRG_RSRV");
        }
        if (!isOpenEd) {
            require(reserveTotal <= params.amount, "RSRV_BIG");
        }

        issuerTokens[allIssuerTokens] = IssuerTokenData({
            author: _msgSender(),
            codexId: codexId,
            metadata: params.metadata,
            inputBytesSize: params.inputBytesSize,
            balance: params.amount,
            iterationsCount: 0,
            supply: params.amount,
            openEditions: params.openEditions,
            hasTickets: hasTickets,
            reserves: params.reserves,
            pricingId: params.pricing.pricingId,
            lockPriceForReserves: params.pricing.lockForReserves,
            primarySplit: params.primarySplit,
            royaltiesSplit: params.royaltiesSplit,
            enabled: params.enabled,
            timestampMinted: block.timestamp,
            lockedSeconds: _lockTime,
            tags: params.tags
        });

        userActions[_msgSender()].lastIssuerMinted = allIssuerTokens;
        userActions[_msgSender()].lastIssuerMintedTime = block.timestamp;

        allIssuerTokens++;
    }

    function mint(MintInput memory params) external payable {
        IssuerTokenData storage issuerToken = issuerTokens[params.issuerId];

        require(issuerToken.author != address(0), "Token undefined");

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

        bool createTicket = params.createTicket.length != 0;
        if (createTicket) {
            require(issuerToken.hasTickets, "ISSUER_NO_TICKETS");
        } else {
            require(
                params.inputBytes.length == issuerToken.inputBytesSize,
                "WRONG_INPUT_BYTES"
            );
        }

        require(isTokenLocked(params.issuerId) == false, "TOKEN_LOCKED");
        require(
            issuerToken.enabled == true || _msgSender() == issuerToken.author,
            "TOKEN_DISABLED"
        );

        bool isOe = issuerToken.openEditions.closingTime > 0;
        if (isOe) {
            OpenEditions memory oe = issuerToken.openEditions;
            if (oe.closingTime != 0) {
                require(block.timestamp < oe.closingTime, "OE_CLOSE");
            }
        } else {
            require(issuerToken.balance > 0, "NO_BLNCE");
        }

        ReserveInput memory reserveInput;
        if (params.reserveInput.length > 0) {
            reserveInput = abi.decode(params.reserveInput, (ReserveInput));
        }

        bool reserveApplied = false;
        uint256 reserveTotal = 0;
        for (uint256 i = 0; i < issuerToken.reserves.length; i++) {
            reserveTotal += issuerToken.reserves[i].amount;
            if (
                reserveInput.methodId == issuerToken.reserves[i].methodId &&
                !reserveApplied
            ) {
                (bool applied, bytes memory applyData) = applyReserve(
                    issuerToken.reserves[i],
                    reserveInput.input
                );
                if (applied) {
                    reserveApplied = true;
                    issuerToken.reserves[i].amount -= 1;
                    issuerToken.reserves[i].data = applyData;
                }
            }
        }

        IPricing pricingContract = IPricing(
            pricingContracts[issuerToken.pricingId].pricingContract
        );

        if (isOe) {
            if (reserveTotal > 0) {
                require(reserveApplied, "ONLY_RSRV");
            }
        } else {
            uint256 balanceWithoutReserve = issuerToken.balance - reserveTotal;
            if ((balanceWithoutReserve <= 0) && (!reserveApplied)) {
                require(
                    !((balanceWithoutReserve <= 0) && (!reserveApplied)),
                    "ONLY_RSRV"
                );
            }
            if (
                issuerToken.lockPriceForReserves &&
                balanceWithoutReserve == 1 &&
                !reserveApplied
            ) {
                pricingContract.lockPrice(params.issuerId);
            }
        }

        uint256 price = pricingContract.getPrice(
            params.issuerId,
            block.timestamp
        );
        require(msg.value >= price, "INVALID_PRICE");

        uint256 platformFees = fees;
        if (params.referrer != address(0) && params.referrer != _msgSender()) {
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
            payable(issuerToken.primarySplit.receiver).transfer(splitAmount);
        }

        if (msg.value > price) {
            uint256 remainingAmount = msg.value - price;
            if (remainingAmount > 0) {
                payable(msg.sender).transfer(remainingAmount);
            }
        }

        if (createTicket) {
            IMintTicket(addresses["mint_tickets"]).mint(
                params.issuerId,
                recipient,
                price
            );
        } else {
            issuerToken.iterationsCount += 1;
            if (issuerToken.royaltiesSplit.receiver == addresses["gentk"]) {}

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

        UserAction storage userAction = userActions[_msgSender()];
        if (userAction.lastMintedTime == block.timestamp) {
            userAction.lastMinted.push(tokenId);
        } else {
            userAction.lastMintedTime = block.timestamp;
            userAction.lastMinted = [tokenId];
        }
    }

    function mintWithTicket(MintWithTicketInput memory params) public {
        IssuerTokenData storage issuerToken = issuerTokens[params.issuerId];
        require(issuerToken.author != address(0), "Token undefined");
        require(
            params.inputBytes.length == issuerToken.inputBytesSize,
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

        IssuerTokenData storage issuerToken = issuerTokens[params.issuerId];
        require(issuerToken.author != address(0), "404");
        require(issuerToken.author == _msgSender(), "403");
        verifyIssuerUpdateable(issuerToken);
        issuerToken.primarySplit = params.primarySplit;
        issuerToken.royaltiesSplit = params.royaltiesSplit;
        issuerToken.enabled = params.enabled;
    }

    function updatePrice(UpdatePriceInput calldata params) external {
        IssuerTokenData storage issuerToken = issuerTokens[params.issuerId];
        require(issuerToken.author != address(0), "404");
        require(issuerToken.author == _msgSender(), "403");
        verifyIssuerUpdateable(issuerToken);
        verifyPricingMethod(params.pricingData.pricingId);
        issuerToken.pricingId = params.pricingData.pricingId;
        issuerToken.lockPriceForReserves = params.pricingData.lockForReserves;
        IPricing(pricingContracts[params.pricingData.pricingId].pricingContract)
            .setPrice(params.issuerId, params.pricingData.details);
    }

    function updateReserve(UpdateReserveInput calldata params) external {
        IssuerTokenData storage issuerToken = issuerTokens[params.issuerId];
        require(issuerToken.author != address(0), "404");
        require(issuerToken.author == _msgSender(), "403");
        verifyIssuerUpdateable(issuerToken);
        require(issuerToken.enabled, "TOK_DISABLED");
        for (uint256 i = 0; i < params.reserves.length; i++) {
            ReserveMethod storage reserve = reserveMethods[
                params.reserves[i].methodId
            ];
            require(
                reserve.reserveContract != IReserve(address(0)),
                "RSRV_404"
            );
            require(reserve.enabled, "RSRV_DIS");
            require(isReserveValid(params.reserves[i]));
        }
        issuerTokens[params.issuerId].reserves = params.reserves;
    }

    function burn(uint256 issuerId) external {
        IssuerTokenData storage issuerToken = issuerTokens[issuerId];
        require(issuerToken.author != address(0), "404");
        require(issuerToken.author == _msgSender(), "403");
        require(issuerToken.balance == issuerToken.supply, "CONSUMED_1");
        burnToken(issuerId);
    }

    function burnSupply(uint256 issuerId, uint256 amount) external {
        require(amount > 0, "TOO_LOW");
        IssuerTokenData storage issuerToken = issuerTokens[issuerId];
        require(issuerToken.author != address(0), "404");
        require(issuerToken.openEditions.closingTime == 0, "OES");
        require(issuerToken.author == _msgSender(), "403");
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
        issuerTokens[issuerId].tags = tags;
    }

    function verifyIssuerUpdateable(
        IssuerTokenData storage issuerToken
    ) private view {
        if (issuerToken.openEditions.closingTime > 0) {
            require(
                block.timestamp < issuerToken.openEditions.closingTime,
                "OE_CLOSE"
            );
        } else {
            require(issuerToken.balance > 0, "NO_BLNC");
        }
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
        override(IERC2981Upgradeable, IFxHashIssuer)
        returns (address receiver, uint256 royaltyAmount)
    {
        RoyaltyData memory royalty = issuerTokens[tokenId].royaltiesSplit;
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
