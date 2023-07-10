// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/abstract/admin/AuthorizedCaller.sol";
import "hardhat/console.sol";

contract Randomizer is AuthorizedCaller {
    bytes32 public constant FXHASH_AUTHORITY = keccak256("FXHASH_AUTHORITY");
    bytes32 public constant FXHASH_ISSUER = keccak256("FXHASH_ISSUER");
    struct TokenKey {
        address issuer;
        uint256 tokenId;
    }

    struct Seed {
        bytes32 chainSeed;
        uint256 serialId;
        bytes32 revealed;
    }

    struct Commitment {
        bytes32 seed;
        bytes32 salt;
    }

    Commitment private commitment;
    uint256 private countRequested;
    uint256 private countRevealed;
    mapping(bytes32 => Seed) public seeds;

    event RandomizerGenerate(uint256 token_id, Seed seed);
    event RandomizerReveal(uint256 id, bytes32 seed);

    constructor(bytes32 _seed, bytes32 _salt) {
        commitment.seed = _seed;
        commitment.salt = _salt;
        countRequested = 0;
        countRevealed = 0;
        _setupRole(DEFAULT_ADMIN_ROLE, address(bytes20(_msgSender())));
        _setupRole(AUTHORIZED_CALLER, address(bytes20(_msgSender())));
    }

    modifier onlyFxHashAuthority() {
        require(
            AccessControl.hasRole(FXHASH_AUTHORITY, _msgSender()),
            "Caller is not a FxHash Authority"
        );
        _;
    }

    modifier onlyFxHashIssuer() {
        require(
            AccessControl.hasRole(FXHASH_ISSUER, _msgSender()),
            "Caller is not a FxHash Issuer"
        );
        _;
    }

    function updateCommitment(bytes32 oracleSeed) private {
        commitment.seed = bytes32(
            uint256(keccak256(abi.encodePacked(oracleSeed)))
        );
    }

    function generate(uint256 tokenId) external onlyFxHashIssuer {
        bytes32 hashedKey = getTokenKey(_msgSender(), tokenId);
        Seed storage storedSeed = seeds[hashedKey];
        require(storedSeed.revealed == 0x00, "ALREADY_SEEDED");
        bytes memory base = abi.encodePacked(block.timestamp, hashedKey);
        bytes32 seed = keccak256(base);
        countRequested += 1;
        storedSeed.chainSeed = seed;
        storedSeed.serialId = countRequested;
        console.log("generated token = ");

        console.logBytes32(hashedKey);

        console.log("generated serial ID = %s", storedSeed.serialId);
        emit RandomizerGenerate(tokenId, storedSeed);
    }

    function reveal(
        TokenKey[] memory tokenList,
        bytes32 seed
    ) external onlyFxHashAuthority {
        uint256 lastSerial = setTokenSeedAndReturnSerial(tokenList[0], seed);
        console.log("lastSerial: %s", lastSerial);

        uint256 expectedSerialId = lastSerial;
        console.log("expectedSerialId: %s", expectedSerialId);

        bytes32 oracleSeed = iterateOracleSeed(seed);
        console.log("oracleSeed:");
        console.logBytes32(oracleSeed);

        for (uint256 i = 1; i < tokenList.length; i++) {
            console.log("i = %s", i);
            expectedSerialId -= 1;
            uint256 serialId = setTokenSeedAndReturnSerial(
                tokenList[i],
                oracleSeed
            );
            console.log("Inside loop - expectedSerialId: %s", expectedSerialId);
            console.log("Inside loop - serialId: %s", serialId);

            require(expectedSerialId == serialId, "OOR");
            oracleSeed = iterateOracleSeed(oracleSeed);
            console.log("Inside loop - oracleSeed:");
            console.logBytes32(oracleSeed);

            emit RandomizerReveal(tokenList[i].tokenId, oracleSeed);
        }

        require(countRevealed + 1 == expectedSerialId, "OOR");
        console.log("countRevealed: %s", countRevealed);

        countRevealed += tokenList.length;
        console.log("oracleSeed:");
        console.logBytes32(oracleSeed);
        console.log("commitment.seed:");
        console.logBytes32(commitment.seed);
        require(oracleSeed == commitment.seed, "OOR");

        updateCommitment(seed);
    }

    function commit(bytes32 seed, bytes32 salt) external onlyFxHashAuthority {
        commitment.seed = seed;
        commitment.salt = salt;
    }

    function grantFxHashAuthorityRole(address _admin) public onlyAdmin {
        AccessControl.grantRole(FXHASH_AUTHORITY, _admin);
    }

    function revokeFxHashAuthorityRole(address _admin) public onlyAdmin {
        AccessControl.revokeRole(FXHASH_AUTHORITY, _admin);
    }

    function grantFxHashIssuerRole(address _admin) public onlyAdmin {
        AccessControl.grantRole(FXHASH_ISSUER, _admin);
    }

    function revokeFxHashIssuerRole(address _admin) public onlyAdmin {
        AccessControl.revokeRole(FXHASH_ISSUER, _admin);
    }

    function getTokenKey(
        address issuer,
        uint256 id
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(issuer, id));
    }

    function setTokenSeedAndReturnSerial(
        TokenKey memory tokenKey,
        bytes32 oracleSeed
    ) private returns (uint256) {
        console.log("setting seed for = ");
        console.logBytes32(getTokenKey(tokenKey.issuer, tokenKey.tokenId));
        Seed storage seed = seeds[
            getTokenKey(tokenKey.issuer, tokenKey.tokenId)
        ];
        require(seed.chainSeed != 0x00, "NO_REQ");
        bytes32 tokenSeed = keccak256(
            abi.encodePacked(oracleSeed, seed.chainSeed)
        );
        seed.revealed = tokenSeed;
        console.log("Fetched serial = %s", seed.serialId);
        return seed.serialId;
    }

    function iterateOracleSeed(
        bytes32 oracleSeed
    ) private view returns (bytes32) {
        return keccak256(abi.encodePacked(commitment.salt, oracleSeed));
    }
}
