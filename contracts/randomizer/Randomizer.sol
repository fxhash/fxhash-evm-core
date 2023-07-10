// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/abstract/admin/AuthorizedCaller.sol";

contract Randomizer is AuthorizedCaller {
    bytes32 public constant FXHASH_AUTHORITY = keccak256("FXHASH_AUTHORITY");
    bytes32 public constant FXHASH_ISSUER = keccak256("FXHASH_ISSUER");
    struct TokenKey {
        address issuer;
        uint256 id;
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
        emit RandomizerGenerate(tokenId, storedSeed);
    }

    function reveal(
        TokenKey[] memory tokens,
        bytes32 seed
    ) external onlyFxHashAuthority {
        TokenKey[] memory tokenList = tokens;
        uint256 lastSerial = setTokenSeedAndReturnSerial(tokenList[0], seed);
        uint256 expectedSerialId = lastSerial;
        bytes32 oracleSeed = iterateOracleSeed(seed);
        for (uint256 i = 0; i < tokenList.length; i++) {
            expectedSerialId -= 1;
            uint256 serialId = setTokenSeedAndReturnSerial(
                tokenList[i],
                oracleSeed
            );
            require(expectedSerialId == serialId, "OOR");
            oracleSeed = iterateOracleSeed(oracleSeed);
            emit RandomizerReveal(tokenList[i].id, oracleSeed);
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
        bytes32 hashedKey = getTokenKey(tokenKey.issuer, tokenKey.id);
        Seed storage seed = seeds[hashedKey];
        require(seed.chainSeed != 0x00, "NO_REQ");
        require(isRequestedVariant(tokenKey), "AL_REV");
        bytes32 tokenSeed = keccak256(
            abi.encodePacked(oracleSeed, seed.chainSeed)
        );
        seed.revealed = tokenSeed;
        return seed.serialId;
    }

    function iterateOracleSeed(
        bytes32 oracleSeed
    ) private view returns (bytes32) {
        return keccak256(abi.encodePacked(commitment.salt, oracleSeed));
    }

    function isRequestedVariant(
        TokenKey memory tokenKey
    ) private view returns (bool) {
        return (seeds[getTokenKey(tokenKey.issuer, tokenKey.id)].chainSeed !=
            0x00);
    }
}
