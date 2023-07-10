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
    mapping(bytes32 => Seed) private seeds;

    event RandomizerGenerate(uint256 token_id, Seed seed);
    event RandomizerReveal(uint256 id, bytes32 seed);

    constructor(bytes32 _seed, bytes32 _salt) {
        commitment.seed = _seed;
        commitment.salt = _salt;
        countRequested = 0;
        countRevealed = 0;
        _setupRole(DEFAULT_ADMIN_ROLE, address(bytes20(msg.sender)));
        _setupRole(AUTHORIZED_CALLER, address(bytes20(msg.sender)));
    }

    modifier onlyFxHashAuthority() {
        require(
            AccessControl.hasRole(FXHASH_AUTHORITY, msg.sender),
            "Caller is not a FxHash Authority"
        );
        _;
    }

    modifier onlyFxHashIssuer() {
        require(AccessControl.hasRole(FXHASH_ISSUER, msg.sender), "Caller is not a FxHash Issuer");
        _;
    }

    function updateCommitment(bytes32 oracleSeed) private {
        commitment.seed = oracleSeed;
    }

    function generate(uint256 tokenId) external onlyFxHashIssuer {
        bytes32 hashedKey = getTokenKey(msg.sender, tokenId);
        Seed storage storedSeed = seeds[hashedKey];
        require(storedSeed.revealed == 0x00, "ALREADY_SEEDED");
        bytes memory base = abi.encode(block.timestamp, hashedKey);
        bytes32 seed = keccak256(base);
        countRequested += 1;
        storedSeed.chainSeed = seed;
        storedSeed.serialId = countRequested;
        emit RandomizerGenerate(tokenId, storedSeed);
    }

    function reveal(TokenKey[] memory tokenList, bytes32 seed) external onlyFxHashAuthority {
        uint256 lastSerial = setTokenSeedAndReturnSerial(tokenList[0], seed);
        uint256 expectedSerialId = lastSerial;
        bytes32 oracleSeed = iterateOracleSeed(seed);
        for (uint256 i = 1; i < tokenList.length; i++) {
            expectedSerialId -= 1;
            uint256 serialId = setTokenSeedAndReturnSerial(tokenList[i], oracleSeed);
            require(expectedSerialId == serialId, "OOR");
            oracleSeed = iterateOracleSeed(oracleSeed);
            emit RandomizerReveal(tokenList[i].tokenId, oracleSeed);
        }

        require(countRevealed + 1 == expectedSerialId, "OOR");
        countRevealed += tokenList.length;
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

    function getTokenKey(address issuer, uint256 id) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(issuer, id));
    }

    function setTokenSeedAndReturnSerial(
        TokenKey memory tokenKey,
        bytes32 oracleSeed
    ) private returns (uint256) {
        Seed storage seed = seeds[getTokenKey(tokenKey.issuer, tokenKey.tokenId)];
        require(seed.chainSeed != 0x00, "NO_REQ");
        bytes32 tokenSeed = keccak256(abi.encode(oracleSeed, seed.chainSeed));
        seed.revealed = tokenSeed;
        return seed.serialId;
    }

    function iterateOracleSeed(bytes32 oracleSeed) private view returns (bytes32) {
        return keccak256(abi.encode(commitment.salt, oracleSeed));
    }
}
