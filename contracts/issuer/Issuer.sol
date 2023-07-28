// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IAllowMint} from "contracts/interfaces/IAllowMint.sol";
import {IAllowMintIssuer} from "contracts/interfaces/IAllowMintIssuer.sol";
import {ICodex} from "contracts/interfaces/ICodex.sol";
import {IConfigurationManager} from "contracts/interfaces/IConfigurationManager.sol";
import {IERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/interfaces/IERC165Upgradeable.sol";
import {IERC2981Upgradeable} from "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import {IGenTk} from "contracts/interfaces/IGenTk.sol";
import {IIssuer} from "contracts/interfaces/IIssuer.sol";
import {IMintTicket} from "contracts/interfaces/IMintTicket.sol";
import {IModerationTeam} from "contracts/interfaces/IModerationTeam.sol";
import {IModerationUser} from "contracts/interfaces/IModerationUser.sol";
import {IOnChainTokenMetadataManager} from "contracts/interfaces/IOnChainTokenMetadataManager.sol";
import {IPricing} from "contracts/interfaces/IPricing.sol";
import {IPricingManager} from "contracts/interfaces/IPricingManager.sol";
import {IReserve} from "contracts/interfaces/IReserve.sol";
import {IReserveManager} from "contracts/interfaces/IReserveManager.sol";
import {LibIssuer} from "contracts/libs/LibIssuer.sol";
import {LibPricing} from "contracts/libs/LibPricing.sol";
import {LibReserve} from "contracts/libs/LibReserve.sol";
import {LibRoyalty} from "contracts/libs/LibRoyalty.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";
import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";

contract Issuer is IIssuer, IERC2981Upgradeable, OwnableUpgradeable {
    IConfigurationManager private configManager;
    LibIssuer.IssuerData private issuer;
    IGenTk private genTk;
    uint256 private allGenTkTokens;

    event IssuerMinted(MintIssuerInput params);
    event IssuerBurned();
    event IssuerUpdated(UpdateIssuerInput params);
    event IssuerModUpdated(uint256[] tags);
    event TokenMinted(MintInput params);
    event TokenMintedWithTicket(MintWithTicketInput params);
    event PriceUpdated(LibPricing.PricingData params);
    event ReserveUpdated(LibReserve.ReserveData[] reserves);
    event SupplyBurned(uint256 amount);

    function initialize(
        address _configManager,
        address _genTk,
        address _owner
    ) external initializer {
        __Ownable_init();
        configManager = IConfigurationManager(_configManager);
        genTk = IGenTk(_genTk);
        transferOwnership(_owner);
    }

    modifier onlyCodex() {
        require(msg.sender == configManager.contracts("codex"), "Caller is not Codex");
        _;
    }

    function mintIssuer(MintIssuerInput calldata params) external {
        require(IAllowMintIssuer(configManager.contracts("al_mi")).isAllowed(msg.sender), "403");
        uint256 codexId = ICodex(configManager.contracts("codex")).insertOrUpdateCodex(
            msg.sender,
            params.codex
        );
        (, , uint128 _lockTime, ) = configManager.config();
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

        IPricingManager(configManager.contracts("priceMag")).verifyPricingMethod(
            params.pricing.pricingId
        );

        IPricing(
            IPricingManager(configManager.contracts("priceMag"))
                .getPricingContract(params.pricing.pricingId)
                .pricingContract
        ).setPrice(params.pricing.details);

        bool hasTickets = params.mintTicketSettings.gracingPeriod > 0;
        if (hasTickets) {
            IMintTicket(configManager.contracts("mint_tickets")).createProject(
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

        (uint128 state, ) = IModerationUser(configManager.contracts("user_mod")).users(msg.sender);
        if (state == 10) _lockTime = 0;

        bool isOpenEd = params.openEditions.closingTime > 0;
        if (isOpenEd) {
            require(block.timestamp + _lockTime < params.openEditions.closingTime, "OES_CLOSING");
        } else {
            require(params.amount > 0, "!SPLY>0");
        }

        uint256 reserveTotal = 0;
        for (uint256 i = 0; i < params.reserves.length; i++) {
            LibReserve.ReserveMethod memory reserveMethod = IReserveManager(
                configManager.contracts("resMag")
            ).getReserveMethod(params.reserves[i].methodId);
            require(reserveMethod.reserveContract != IReserve(address(0)), "NO_RESERVE_METHOD");
            require(reserveMethod.enabled, "RESERVE_METHOD_DISABLED");
            reserveTotal += params.reserves[i].amount;
            require(
                IReserveManager(configManager.contracts("resMag")).isReserveValid(
                    params.reserves[i],
                    msg.sender
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

        emit IssuerMinted(params);
    }

    function mint(MintInput memory params) external payable {
        require(issuer.supply > 0, "Token undefined");
        require(address(genTk) != address(0), "GENTK_NOT_SET");

        require(IAllowMint(configManager.contracts("al_m")).isAllowed(address(this)), "403");

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
            IPricingManager(configManager.contracts("priceMag"))
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
                        configManager.contracts("resMag")
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
        require(address(genTk) != address(0), "GENTK_NOT_SET");

        address recipient = msg.sender;
        if (params.recipient != address(0)) {
            recipient = params.recipient;
        }
        IMintTicket(configManager.contracts("mint_tickets")).consume(
            msg.sender,
            params.ticketId,
            address(this)
        );

        (, , , string memory defaultMetadata) = configManager.config();

        issuer.iterationsCount += 1;
        genTk.mint(
            IGenTk.TokenParams({
                tokenId: allGenTkTokens,
                iteration: issuer.iterationsCount,
                inputBytes: params.inputBytes,
                receiver: issuer.royaltiesSplit.receiver == address(genTk)
                    ? recipient
                    : issuer.royaltiesSplit.receiver,
                metadata: defaultMetadata
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
        IPricingManager(configManager.contracts("priceMag")).verifyPricingMethod(
            pricingData.pricingId
        );
        issuer.info.pricingId = pricingData.pricingId;
        issuer.info.lockPriceForReserves = pricingData.lockForReserves;
        IPricing(
            IPricingManager(configManager.contracts("priceMag"))
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
                configManager.contracts("resMag")
            ).getReserveMethod(reserves[i].methodId);
            require(reserve.reserveContract != IReserve(address(0)), "RSRV_404");
            require(reserve.enabled, "RSRV_DIS");
            require(
                IReserveManager(configManager.contracts("resMag")).isReserveValid(
                    reserves[i],
                    msg.sender
                )
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
            IModerationTeam(configManager.contracts("mod_team")).isAuthorized(msg.sender, 10),
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
    )
        public
        view
        override(IERC2981Upgradeable, IIssuer)
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
    ) public pure override(IERC165Upgradeable, IIssuer) returns (bool) {
        return
            interfaceId == type(IIssuer).interfaceId ||
            interfaceId == type(IERC2981Upgradeable).interfaceId;
    }

    function burnToken() private {
        delete issuer;
    }

    function owner() public view override(IIssuer, OwnableUpgradeable) returns (address) {
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
            require(msg.value >= price && price > 0, "INVALID_PRICE");
            (
                uint64 feeShare,
                uint64 referrerShare,
                uint128 lockTime,
                string memory defaultMetadata
            ) = configManager.config();
            uint256 platformFees = feeShare;
            if (params.referrer != address(0) && params.referrer != msg.sender) {
                uint256 referrerFees = (feeShare * referrerShare) / 10000;
                uint256 referrerAmount = (price * referrerFees) / 10000;
                if (referrerAmount > 0) {
                    SafeTransferLib.safeTransferETH(params.referrer, referrerAmount);
                }
                platformFees = feeShare - referrerFees;
            }

            uint256 feesAmount = (price * platformFees) / 10000;
            if (feesAmount > 0) {
                SafeTransferLib.safeTransferETH(configManager.contracts("treasury"), feesAmount);
            }

            uint256 creatorAmount = price - feesAmount;
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
                IMintTicket(configManager.contracts("mint_tickets")).mint(recipient, price);
            } else {
                issuer.iterationsCount += 1;
                genTk.mint(
                    IGenTk.TokenParams({
                        tokenId: tokenId,
                        iteration: issuer.iterationsCount,
                        inputBytes: params.inputBytes,
                        receiver: issuer.royaltiesSplit.receiver == address(genTk)
                            ? recipient
                            : issuer.royaltiesSplit.receiver,
                        metadata: defaultMetadata
                    })
                );
                allGenTkTokens++;
            }
        }
    }
}
