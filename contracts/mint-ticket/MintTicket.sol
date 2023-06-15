// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "contracts/abstract/admin/FxHashAdminVerify.sol";
import "contracts/interfaces/IFxHashIssuer.sol";
import "contracts/interfaces/IRandomizer.sol";
import "contracts/interfaces/IMintTicket.sol";
import "hardhat/console.sol";

contract MintTicket is
    ERC721URIStorageUpgradeable,
    IERC2981Upgradeable,
    FxHashAdminVerify,
    IMintTicket
{
    function _msgData()
        internal
        view
        override(Context, ContextUpgradeable)
        returns (bytes calldata)
    {
        return ContextUpgradeable._msgData();
    }

    function _msgSender()
        internal
        view
        override(Context, ContextUpgradeable)
        returns (address)
    {
        return ContextUpgradeable._msgSender();
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(
            AccessControl,
            ERC721URIStorageUpgradeable,
            IERC165Upgradeable,
            IMintTicket
        )
        returns (bool)
    {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    modifier onlyFxHashIssuer() {
        require(_msgSender() == address(issuer), "NO_ISSUER");
        _;
    }

    mapping(uint256 => TokenData) public tokenData;
    mapping(uint256 => ProjectData) public projectData;
    uint256 public lastTokenId;
    uint256 public fees;
    uint256 public availableBalance;
    uint256 public minPrice;
    IFxHashIssuer public issuer;
    IRandomizer public randomizer;

    constructor(address _admin, address _issuer, address _randomizer) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(FXHASH_ADMIN, _admin);
        issuer = IFxHashIssuer(_issuer);
        randomizer = IRandomizer(_randomizer);
        lastTokenId = 0;
        fees = 0;
        availableBalance = 0;
        minPrice = 100000;
    }

    // Helpers

    function dailyTaxAmount(uint256 price) internal pure returns (uint256) {
        return (price * 14) / 10000;
    }

    function taxationStartDate(
        uint256 tokenId
    ) internal view returns (uint256) {
        TokenData storage token = tokenData[tokenId];
        ProjectData storage project = projectData[token.projectId];
        return token.createdAt + project.gracingPeriod * 1 days;
    }

    function isGracingByTime(
        uint256 tokenId,
        uint256 time
    ) internal view returns (bool) {
        return taxationStartDate(tokenId) - time > 0;
    }

    function isGracing(uint256 tokenId) internal view returns (bool) {
        return isGracingByTime(tokenId, block.timestamp);
    }

    function distanceForeclosureByTime(
        uint256 tokenId,
        uint256 time
    ) internal view returns (uint256) {
        TokenData storage token = tokenData[tokenId];
        uint256 dailyTax = dailyTaxAmount(token.price);
        uint256 daysCovered = token.taxationLocked / dailyTax;
        uint256 foreclosureTime = token.taxationStart + daysCovered * 1 days;
        return time - foreclosureTime;
    }

    function distanceForeclosure(
        uint256 tokenId
    ) internal view returns (uint256) {
        return distanceForeclosureByTime(tokenId, block.timestamp);
    }

    function isForeclosureByTime(
        uint256 tokenId,
        uint256 time
    ) internal view returns (bool) {
        TokenData storage token = tokenData[tokenId];
        uint256 dailyTax = dailyTaxAmount(token.price);
        uint256 daysCovered = token.taxationLocked / dailyTax;
        uint256 secondsSincePayment = time > token.taxationStart
            ? time - token.taxationStart
            : 0;
        uint256 daysSincePayment = secondsSincePayment / 1 days;
        return
            (!isGracingByTime(tokenId, time)) &&
            (daysSincePayment >= daysCovered);
    }

    function isForeclosure(uint256 tokenId) internal view returns (bool) {
        return isForeclosureByTime(tokenId, block.timestamp);
    }

    function isOwnerByTime(
        address owner,
        uint256 tokenId,
        uint256 time
    ) internal view returns (bool) {
        return
            (ownerOf(tokenId) == owner) &&
            (!isForeclosureByTime(tokenId, time));
    }

    function isOwner(
        address owner,
        uint256 tokenId
    ) internal view returns (bool) {
        return isOwnerByTime(owner, tokenId, block.timestamp);
    }

    function send(address recipient, uint256 amount) internal {
        if (amount > 0) {
            payable(recipient).transfer(amount);
        }
    }

    function foreclosurePrice(
        uint256 price,
        uint256 secondsElapsed
    ) internal view returns (uint256) {
        uint256 T = (secondsElapsed * 10000) / 1 days;
        uint256 prange = price - minPrice; // TODO Check this value
        return price - (prange * T) / 10000;
    }

    function taxRelease(
        uint256 tokenId
    ) internal view returns (uint256, uint256) {
        TokenData storage token = tokenData[tokenId];
        uint256 timeDiff = 0;
        if (block.timestamp > token.taxationStart) {
            timeDiff = block.timestamp - token.taxationStart;
        }
        uint256 daysSinceLastTaxation = timeDiff / 1 days;
        uint256 dailyTax = dailyTaxAmount(token.price);
        uint256 taxToPay = dailyTax * daysSinceLastTaxation;
        if (taxToPay > token.taxationLocked) {
            taxToPay = token.taxationLocked;
        }
        uint256 taxToRelease = token.taxationLocked - taxToPay;
        return (taxToPay, taxToRelease);
    }

    function payProjectAuthorsWithSplit(
        uint256 projectId,
        uint256 amount
    ) internal {
        if (amount > 0) {
            (address receiver, uint256 royaltyAmount) = issuer
                .getTokenPrimarySplit(projectId, amount);
            payable(receiver).transfer(royaltyAmount);
        }
    }

    // Entry Points

    function setMinPrice(uint256 price) external onlyAdmin {
        minPrice = price;
    }

    function setFees(uint256 _fees) external onlyAdmin {
        fees = _fees;
    }

    function setIssuer(address _issuer) external onlyAdmin {
        issuer = IFxHashIssuer(_issuer);
    }

    function setRandomizer(address _randomizer) external onlyAdmin {
        randomizer = IRandomizer(_randomizer);
    }

    receive() external payable {
        availableBalance = availableBalance + msg.value;
    }

    function withdraw(uint256 amount, address to) external onlyAdmin {
        uint256 withdrawAmount = amount > 0 ? amount : availableBalance;
        require(withdrawAmount <= availableBalance, "OVER_AVAILABLE_BALANCE");
        availableBalance -= withdrawAmount;
        payable(to).transfer(withdrawAmount);
    }

    function createProject(
        uint256 projectId,
        uint256 gracingPeriod,
        string calldata metadata
    ) external onlyFxHashIssuer {
        require(projectData[projectId].gracingPeriod == 0, "PROJECT_EXISTS");
        require(gracingPeriod > 0, "GRACING_UNDER_1");
        projectData[projectId] = ProjectData({
            gracingPeriod: gracingPeriod,
            metadata: metadata
        });
    }

    function mint(
        uint256 projectId,
        address minter,
        uint256 price
    ) external onlyFxHashIssuer {
        ProjectData storage project = projectData[projectId];
        require(project.gracingPeriod > 0, "PROJECT_DOES_NOT_EXISTS");
        uint256 tokenId = lastTokenId;
        _mint(minter, tokenId);
        _setTokenURI(tokenId, project.metadata);
        tokenData[tokenId] = TokenData(
            projectId,
            minter,
            block.timestamp,
            0,
            block.timestamp + projectData[projectId].gracingPeriod * 1 days,
            price < minPrice ? minPrice : price
        );
        lastTokenId++;
    }

    function updatePrice(
        uint256 tokenId,
        uint256 price,
        uint256 coverage
    ) external payable {
        TokenData storage token = tokenData[tokenId];
        require(token.minter != address(0), "TOKEN_DOES_NOT_EXIST");
        require(isOwner(_msgSender(), tokenId), "INSUFFICIENT_BALANCE");
        require(price >= minPrice, "PRICE_BELOW_MIN_PRICE");
        require(coverage > 0, "MIN_1_COVERAGE");

        uint256 daysSinceCreated = (block.timestamp - token.createdAt) / 1 days;
        uint256 startDay = token.createdAt + daysSinceCreated * 1 days;

        if (block.timestamp < token.taxationStart) {
            uint256 gracingRemainingDays = projectData[token.projectId]
                .gracingPeriod - daysSinceCreated;
            require(coverage > gracingRemainingDays, "COVERAGE_GRACED");
            uint256 newDailyTax = dailyTaxAmount(price);
            uint256 taxRequiredForCoverage = newDailyTax *
                (coverage - gracingRemainingDays);
            uint256 totalAvailable = msg.value + token.taxationLocked;
            require(
                totalAvailable >= taxRequiredForCoverage,
                "NOT_ENOUGH_FOR_COVERAGE"
            );

            uint256 sendBackAmount = totalAvailable - taxRequiredForCoverage;
            send(_msgSender(), sendBackAmount);

            token.taxationLocked = taxRequiredForCoverage;
            token.price = price;
        } else {
            {
                uint256 daysSinceLastTaxation = (block.timestamp -
                    token.taxationStart) / 1 days;
                uint256 dailyTax = dailyTaxAmount(token.price);
                uint256 taxToPay = dailyTax * daysSinceLastTaxation;

                payProjectAuthorsWithSplit(token.projectId, taxToPay);

                uint256 taxLeft = token.taxationLocked - taxToPay;
                uint256 newDailyTax = dailyTaxAmount(price);
                uint256 taxRequiredForCoverage = newDailyTax * coverage;
                uint256 totalAvailable = msg.value + taxLeft;

                require(
                    totalAvailable >= taxRequiredForCoverage,
                    "NOT_ENOUGH_FOR_COVERAGE"
                );

                uint256 sendBackAmount = totalAvailable -
                    taxRequiredForCoverage;
                send(_msgSender(), sendBackAmount);

                token.taxationLocked = taxRequiredForCoverage;
                token.taxationStart = startDay;
                token.price = price;
            }
        }
    }

    function payTax(uint256 tokenId) external payable {
        TokenData storage token = tokenData[tokenId];
        require(token.minter != address(0), "TOKEN_DOES_NOT_EXIST");
        uint256 dailyTax = dailyTaxAmount(token.price);
        uint256 daysCoverage = msg.value / dailyTax;
        uint256 cleanCoverage = dailyTax * daysCoverage;
        send(_msgSender(), msg.value - cleanCoverage);
        token.taxationLocked = token.taxationLocked + cleanCoverage;
    }

    function claim(
        uint256 tokenId,
        uint256 price,
        uint256 coverage,
        address transferTo
    ) external payable {
        TokenData storage token = tokenData[tokenId];
        require(token.minter != address(0), "TOKEN_DOES_NOT_EXIST");
        require(!isGracing(tokenId), "GRACING_PERIOD");
        require(price >= minPrice, "PRICE_BELOW_MIN_PRICE");
        require(coverage > 0, "MIN_1_COVERAGE");
        address owner = ownerOf(tokenId);
        uint256 distanceFc = distanceForeclosure(tokenId);
        if (distanceFc >= 0) {
            if (distanceFc > 1 days) {
                distanceFc = 1 days;
            }
            price = foreclosurePrice(price, distanceFc);
        }

        uint256 taxAmount = dailyTaxAmount(price) * coverage;
        uint256 amountRequired = taxAmount * price;
        require(msg.value >= amountRequired, "AMOUNT_UNDER_PRICE");

        send(_msgSender(), msg.value - amountRequired);
        send(owner, price);

        (uint256 taxToPay, uint256 taxToRelease) = taxRelease(tokenId);
        payProjectAuthorsWithSplit(token.projectId, taxToPay);
        send(owner, taxToRelease);
        uint256 startDay = token.createdAt +
            ((block.timestamp - token.createdAt) / 1 days) *
            1 days;
        token.taxationLocked = taxAmount;
        token.taxationStart = startDay;
        token.price = price;
        if (transferTo != address(0)) {
            safeTransferFrom(owner, transferTo, tokenId);
        }
    }

    function consume(
        address owner,
        uint256 tokenId,
        uint256 projectId
    ) external payable onlyFxHashIssuer {
        TokenData storage token = tokenData[tokenId];
        require(token.minter != address(0), "TOKEN_DOES_NOT_EXIST");
        require(isOwner(owner, tokenId), "INSUFFICIENT_BALANCE");
        require(token.projectId == projectId, "WRONG_PROJECT");
        (uint256 taxToPay, uint256 taxToRelease) = taxRelease(tokenId);
        payProjectAuthorsWithSplit(token.projectId, taxToPay);
        send(owner, taxToRelease);
        randomizer.generate(tokenId);
        delete tokenData[tokenId];
        delete projectData[projectId];
        _burn(tokenId);
    }

    function tokensOf(address owner) external view returns (uint256[] memory) {
        uint256 balance = balanceOf(owner);
        uint256[] memory tokens = new uint256[](balance);
        uint256 tokenIdx = 0;
        for (uint256 i = 0; i <= lastTokenId; i++) {
            if (isOwnerByTime(owner, i, block.timestamp)) {
                tokens[tokenIdx] = i;
                tokenIdx++;
            }
        }
        return tokens;
    }

    function balanceOf(
        address owner
    )
        public
        view
        override(ERC721Upgradeable, IERC721Upgradeable, IMintTicket)
        returns (uint256)
    {
        uint256 balance = 0;
        for (uint256 i = 0; i <= lastTokenId; i++) {
            if (isOwnerByTime(owner, i, block.timestamp)) {
                balance++;
            }
        }
        return balance;
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        public
        virtual
        override(ERC721Upgradeable, IERC721Upgradeable, IMintTicket)
    {
        require(isOwner(from, tokenId), "MUST_BE_OWNER");
        ERC721Upgradeable.transferFrom(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        public
        virtual
        override(ERC721Upgradeable, IERC721Upgradeable, IMintTicket)
    {
        require(isOwner(from, tokenId));
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    )
        public
        virtual
        override(ERC721Upgradeable, IERC721Upgradeable, IMintTicket)
    {
        require(isOwner(from, tokenId));
        ERC721Upgradeable.safeTransferFrom(from, to, tokenId, data);
    }

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    )
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {}
}
