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
import "contracts/interfaces/IOnChainTokenMetadataManager.sol";
import "contracts/interfaces/IConfigurationManager.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SignedMath.sol";
import "@rari-capital/solmate/src/utils/SafeTransferLib.sol";

import "contracts/libs/LibIssuer.sol";
import "contracts/libs/LibReserve.sol";

contract Issuer is IIssuer, IERC2981, Ownable {
    uint256 private allGenTkTokens;
    IConfigurationManager private configManager;
    LibIssuer.IssuerData private issuer;

    event IssuerMinted(MintIssuerInput params);
    event IssuerBurned();
    event IssuerUpdated(UpdateIssuerInput params);
    event IssuerModUpdated(uint256[] tags);
    event TokenMinted(MintInput params);
    event TokenMintedWithTicket(MintWithTicketInput params);
    event PriceUpdated(LibPricing.PricingData params);
    event ReserveUpdated(LibReserve.ReserveData[] reserves);
    event SupplyBurned(uint256 amount);
    event RoyaltySplit(
        address indexed token,
        address[] accounts,
        uint32[] allocations,
        uint256 percent
    );

    constructor(address _configManager, address _owner) {
        configManager = IConfigurationManager(_configManager);
        allGenTkTokens = 0;
        transferOwnership(_owner);
    }

    modifier onlyCodex() {
        require(msg.sender == configManager.getAddress("codex"), "Caller is not Codex");
        _;
    }

    function mintIssuer(MintIssuerInput calldata params) external {
        require(IAllowMintIssuer(configManager.getAddress("al_mi")).isAllowed(msg.sender), "403");
        uint256 codexId = ICodex(configManager.getAddress("codex")).insertOrUpdateCodex(
            msg.sender,
            params.codex
        );
        uint256 _lockTime = configManager.getConfig().lockTime;
        require(
            ((params.royaltiesSplit.percent >= 1000) && (params.royaltiesSplit.percent <= 2500)) ||
                ((!params.enabled) && (params.royaltiesSplit.percent <= 2500)),
            "WRG_ROY"
        );
        require(
            ((params.primarySplit.percent >= 1000) && (params.primarySplit.percent <= 2500)),
            "WRG_PRIM_SPLIT"
        );

        require(issuer.supply == 0, "409");

        IPricingManager(configManager.getAddress("priceMag")).verifyPricingMethod(
            params.pricing.pricingId
        );

        IPricing(
            IPricingManager(configManager.getAddress("priceMag"))
                .getPricingContract(params.pricing.pricingId)
                .pricingContract
        ).setPrice(params.pricing.details);

        bool hasTickets = params.mintTicketSettings.gracingPeriod > 0;
        if (hasTickets) {
            IMintTicket(configManager.getAddress("mint_tickets")).createProject(
                params.mintTicketSettings.gracingPeriod,
                params.mintTicketSettings.metadata
            );
        }

        //TODO: once we have the collaboration factory, we need to update that
        // if (isCollaborationContract(sp.sender)) {
        //     Set.setAddresses storage collaborators = getCollaborators(sp.sender);
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

        if (IModerationUser(configManager.getAddress("user_mod")).userState(msg.sender) == 10) {
            _lockTime = 0;
        }
        //}
        bool isOpenEd = params.openEditions.closingTime > 0;
        if (isOpenEd) {
            require(block.timestamp + _lockTime < params.openEditions.closingTime, "OES_CLOSING");
        } else {
            require(params.amount > 0, "!SPLY>0");
        }

        uint256 reserveTotal = 0;
        for (uint256 i = 0; i < params.reserves.length; i++) {
            LibReserve.ReserveMethod memory reserveMethod = IReserveManager(
                configManager.getAddress("resMag")
            ).getReserveMethod(params.reserves[i].methodId);
            require(reserveMethod.reserveContract != IReserve(address(0)), "NO_RESERVE_METHOD");
            require(reserveMethod.enabled, "RESERVE_METHOD_DISABLED");
            reserveTotal += params.reserves[i].amount;
            require(
                IReserveManager(configManager.getAddress("resMag")).isReserveValid(
                    params.reserves[i]
                ),
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
        address gentkContract = configManager.getAddress("gentk");
        emit IssuerMinted(params);
    }

    function mint(MintInput memory params) external payable {
        require(issuer.supply > 0, "Token undefined");

        require(IAllowMint(configManager.getAddress("al_m")).isAllowed(address(this)), "403");

        uint256 tokenId = allGenTkTokens;

        address recipient = msg.sender;
        if (params.recipient != address(0)) {
            recipient = params.recipient;
        }

        if (params.createTicket == true) {
            require(issuer.info.hasTickets, "ISSUER_NO_TICKETS");
        } else {
            require(params.inputBytes.length == issuer.info.inputBytesSize, "WRONG_INPUT_BYTES");
        }

        require(
            SignedMath.abs(int256(block.timestamp) - int256(issuer.info.timestampMinted)) >
                issuer.info.lockedSeconds,
            "TOKEN_LOCKED"
        );
        require(issuer.info.enabled == true || msg.sender == owner(), "TOKEN_DISABLED");

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
            reserveInput = abi.decode(params.reserveInput, (LibReserve.ReserveInput));
        }

        IPricing pricingContract = IPricing(
            IPricingManager(configManager.getAddress("priceMag"))
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
                if (reserveInput.methodId == decodedReserves[i].methodId && !reserveApplied) {
                    (bool applied, bytes memory applyData) = IReserveManager(
                        configManager.getAddress("resMag")
                    ).applyReserve(decodedReserves[i], reserveInput.input, msg.sender);
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
                    require(!((balanceWithoutReserve <= 0) && (!reserveApplied)), "ONLY_RSRV");
                }
                if (
                    issuer.info.lockPriceForReserves &&
                    balanceWithoutReserve == 1 &&
                    !reserveApplied
                ) {
                    pricingContract.lockPrice();
                }
            }
        }

        processTransfers(pricingContract, params, tokenId, recipient);

        emit TokenMinted(params);
    }

    function mintWithTicket(MintWithTicketInput memory params) external {
        require(params.inputBytes.length == issuer.info.inputBytesSize, "WRONG_INPUT_BYTES");

        address recipient = msg.sender;
        if (params.recipient != address(0)) {
            recipient = params.recipient;
        }
        IMintTicket(configManager.getAddress("mint_tickets")).consume(
            msg.sender,
            params.ticketId,
            address(this)
        );

        issuer.iterationsCount += 1;
        address gentkContract = configManager.getAddress("gentk");
        IGenTk(gentkContract).mint(
            IGenTk.TokenParams({
                tokenId: allGenTkTokens,
                iteration: issuer.iterationsCount,
                inputBytes: params.inputBytes,
                receiver: issuer.royaltiesSplit.receiver == gentkContract
                    ? recipient
                    : issuer.royaltiesSplit.receiver,
                metadata: configManager.getConfig().voidMetadata
            })
        );

        allGenTkTokens++;

        emit TokenMintedWithTicket(params);
    }

    function updateIssuer(UpdateIssuerInput calldata params) external onlyOwner {
        LibIssuer.verifyIssuerUpdateable(issuer);

        require(
            ((params.royaltiesSplit.percent >= 1000) && (params.royaltiesSplit.percent <= 2500)) ||
                ((!params.enabled) && (params.royaltiesSplit.percent <= 2500)),
            "WRG_ROY"
        );
        require(
            ((params.primarySplit.percent >= 1000) && (params.primarySplit.percent <= 2500)),
            "WRG_PRIM_SPLIT"
        );

        issuer.primarySplit = params.primarySplit;
        issuer.royaltiesSplit = params.royaltiesSplit;
        issuer.info.enabled = params.enabled;
        emit IssuerUpdated(params);
    }

    function updatePrice(LibPricing.PricingData calldata pricingData) external onlyOwner {
        LibIssuer.verifyIssuerUpdateable(issuer);
        IPricingManager(configManager.getAddress("priceMag")).verifyPricingMethod(
            pricingData.pricingId
        );
        issuer.info.pricingId = pricingData.pricingId;
        issuer.info.lockPriceForReserves = pricingData.lockForReserves;
        IPricing(
            IPricingManager(configManager.getAddress("priceMag"))
                .getPricingContract(pricingData.pricingId)
                .pricingContract
        ).setPrice(pricingData.details);
        emit PriceUpdated(pricingData);
    }

    function updateReserve(LibReserve.ReserveData[] calldata reserves) external onlyOwner {
        LibIssuer.verifyIssuerUpdateable(issuer);
        require(issuer.info.enabled, "TOK_DISABLED");
        for (uint256 i = 0; i < reserves.length; i++) {
            LibReserve.ReserveMethod memory reserve = IReserveManager(
                configManager.getAddress("resMag")
            ).getReserveMethod(reserves[i].methodId);
            require(reserve.reserveContract != IReserve(address(0)), "RSRV_404");
            require(reserve.enabled, "RSRV_DIS");
            require(
                IReserveManager(configManager.getAddress("resMag")).isReserveValid(reserves[i])
            );
        }
        issuer.reserves = abi.encode(reserves);
        emit ReserveUpdated(reserves);
    }

    function burn() external onlyOwner {
        require(issuer.balance == issuer.supply, "CONSUMED_1");
        burnToken();
        emit IssuerBurned();
    }

    function burnSupply(uint256 amount) external onlyOwner {
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

    function updateIssuerMod(uint256[] calldata tags) external {
        require(
            IModeration(configManager.getAddress("mod_team")).isAuthorized(msg.sender, 10),
            "403"
        );
        issuer.info.tags = tags;
        emit IssuerModUpdated(tags);
    }

    function setCodex(uint256 codexId) external onlyCodex {
        issuer.info.codexId = codexId;
    }

    function setConfigurationManager(address _configManager) external onlyOwner {
        configManager = IConfigurationManager(_configManager);
    }

    function getIssuer() external view returns (LibIssuer.IssuerData memory) {
        return issuer;
    }

    function royaltyInfo(
        uint256,
        uint256 salePrice
    ) public view override(IERC2981, IIssuer) returns (address receiver, uint256 royaltyAmount) {
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
    ) public pure override(IERC165, IIssuer) returns (bool) {
        return
            interfaceId == type(IIssuer).interfaceId || interfaceId == type(IERC2981).interfaceId;
    }

    function burnToken() private {
        delete issuer;
    }

    function owner() public view override(IIssuer, Ownable) returns (address) {
        return super.owner();
    }

    function processTransfers(
        IPricing pricingContract,
        MintInput memory params,
        uint256 tokenId,
        address recipient
    ) private {
        {
            uint256 price = pricingContract.getPrice(block.timestamp);
            require(msg.value >= price, "INVALID_PRICE");

            uint256 platformFees = configManager.getConfig().fees;
            if (params.referrer != address(0) && params.referrer != msg.sender) {
                uint256 referrerFees = (configManager.getConfig().fees *
                    configManager.getConfig().referrerFeesShare) / 10000;
                uint256 referrerAmount = (price * referrerFees) / 10000;
                if (referrerAmount > 0) {
                    SafeTransferLib.safeTransferETH(params.referrer, referrerAmount);
                }
                platformFees = configManager.getConfig().fees - referrerFees;
            }

            uint256 feesAmount = (price * platformFees) / 10000;
            if (feesAmount > 0) {
                SafeTransferLib.safeTransferETH(configManager.getAddress("treasury"), feesAmount);
            }

            uint256 creatorAmount = price - (msg.value - feesAmount);
            uint256 splitAmount = (creatorAmount * issuer.primarySplit.percent) / 10000;
            if (splitAmount > 0) {
                SafeTransferLib.safeTransferETH(issuer.primarySplit.receiver, splitAmount);
            }

            if (msg.value > price) {
                uint256 remainingAmount = msg.value - price;
                if (remainingAmount > 0) {
                    SafeTransferLib.safeTransferETH(msg.sender, remainingAmount);
                }
            }

            if (params.createTicket == true) {
                IMintTicket(configManager.getAddress("mint_tickets")).mint(recipient, price);
            } else {
                issuer.iterationsCount += 1;
                address gentkContract = configManager.getAddress("gentk");
                IGenTk(gentkContract).mint(
                    IGenTk.TokenParams({
                        tokenId: tokenId,
                        iteration: issuer.iterationsCount,
                        inputBytes: params.inputBytes,
                        receiver: issuer.royaltiesSplit.receiver == gentkContract
                            ? recipient
                            : issuer.royaltiesSplit.receiver,
                        metadata: configManager.getConfig().voidMetadata
                    })
                );
                allGenTkTokens++;
            }
        }
    }
}
