pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "contracts/libs/lib-admin/LibAdmin.sol";
import "hardhat/console.sol";

contract Randomizer is AccessControl{
    struct TokenKey {
        address issuer;
        uint256 id;
    }

    struct Seed {
        bytes32 chain_seed;
        uint256 serial_id;
        bytes32 revealed;
    }

    struct Commitment {
        bytes32 seed;
        bytes32 salt;
    }

    Commitment public commitment;
    uint256 public count_requested;
    uint256 public count_revealed;
    mapping(bytes32 => Seed) public seeds;

    modifier onlyAdmin() {
        require(
            AccessControl.hasRole(
                AccessControl.DEFAULT_ADMIN_ROLE,
                _msgSender()
            ),
            "Caller is not an admin"
        );
        _;
    }

    modifier onlyFxHashAdmin() {
        require(
            AccessControl.hasRole(LibAdmin.FXHASH_ADMIN, _msgSender()),
            "Caller is not a FxHash admin"
        );
        _;
    }

    modifier onlyFxHashAuthority() {
        require(
            AccessControl.hasRole(LibAdmin.FXHASH_AUTHORITY, _msgSender()),
            "Caller is not a FxHash Authority"
        );
        _;
    }

    modifier onlyFxHashIssuer() {
        require(
            AccessControl.hasRole(LibAdmin.FXHASH_ISSUER, _msgSender()),
            "Caller is not a FxHash Issuer"
        );
        _;
    }

    constructor(bytes32 _seed, bytes32 _salt) {
        commitment.seed = _seed;
        commitment.salt = _salt;
        count_requested = 0;
        count_revealed = 0;
        _setupRole(DEFAULT_ADMIN_ROLE, address(bytes20(_msgSender())));
        _setupRole(LibAdmin.FXHASH_ADMIN, address(bytes20(_msgSender())));
    }

    function setTokenSeedAndReturnSerial(TokenKey memory tokenKey, bytes32 oracleSeed) private returns (uint256) {
        bytes32 hashedKey = getTokenKey(tokenKey.issuer, tokenKey.id);
        Seed storage seed = seeds[hashedKey];
        require(seed.chain_seed != 0x00, "NO_REQ");
        require(isRequestedVariant(tokenKey), "AL_REV");
        bytes32 tokenSeed = keccak256(abi.encodePacked(oracleSeed, seed.chain_seed));
        seed.revealed = tokenSeed;
        return seed.serial_id;
    }

    function iterateOracleSeed(bytes32 oracleSeed) private view returns (bytes32) {
        return keccak256(abi.encodePacked(commitment.salt, oracleSeed));
    }

    function updateCommitment(bytes32 oracleSeed) private {
        commitment.seed = bytes32(uint256(keccak256(abi.encodePacked(oracleSeed))));
    }

    function generate(uint256 token_id) external onlyFxHashIssuer{
        bytes32 hashedKey = getTokenKey(_msgSender(), token_id);
        console.logBytes32(seeds[hashedKey].revealed);
        require(seeds[hashedKey].revealed == 0x00, "ALREADY_SEEDED");
        bytes memory base = abi.encodePacked(block.timestamp, hashedKey);
        bytes32 seed = keccak256(base);
        count_requested += 1;
        seeds[hashedKey].chain_seed = seed;
        seeds[hashedKey].serial_id = count_requested;
    }

    function reveal(TokenKey[] memory tokens, bytes32 seed) external onlyFxHashAuthority{
        TokenKey[] memory tokenList = tokens;
        uint256 lastSerial = setTokenSeedAndReturnSerial(tokenList[0], seed);
        uint256 expectedSerialId = lastSerial;
        bytes32 oracleSeed = iterateOracleSeed(seed);
        for (uint256 i = 0; i < tokenList.length; i++) {
            expectedSerialId -= 1;
            uint256 serialId = setTokenSeedAndReturnSerial(tokenList[i], oracleSeed);
            require(expectedSerialId == serialId, "OOR");
            oracleSeed = iterateOracleSeed(oracleSeed);
        }
        require(count_revealed + 1 == expectedSerialId, "OOR");
        count_revealed += tokenList.length;
        require(oracleSeed == commitment.seed, "OOR");
        updateCommitment(seed);
    }

    function commit(bytes32 seed, bytes32 salt) external onlyFxHashAuthority{
        commitment.seed = seed;
        commitment.salt = salt;
    }

    // Function to grant the ADMIN_ROLE to an address
    function grantAdminRole(address _admin) public onlyAdmin {
        AccessControl.grantRole(AccessControl.DEFAULT_ADMIN_ROLE, _admin);
    }

    // Function to revoke the ADMIN_ROLE from an address
    function revokeAdminRole(address _admin) public onlyAdmin {
        AccessControl.revokeRole(AccessControl.DEFAULT_ADMIN_ROLE, _admin);
    }

    function grantFxHashAdminRole(address _admin) public onlyAdmin {
        AccessControl.grantRole(LibAdmin.FXHASH_ADMIN, _admin);
    }

    function revokeFxHashAdminRole(address _admin) public onlyAdmin {
        AccessControl.revokeRole(LibAdmin.FXHASH_ADMIN, _admin);
    }

    function grantFxHashAuthorityRole(address _admin) public onlyAdmin {
        AccessControl.grantRole(LibAdmin.FXHASH_AUTHORITY, _admin);
    }

    function revokeFxHashAuthorityRole(address _admin) public onlyAdmin {
        AccessControl.revokeRole(LibAdmin.FXHASH_AUTHORITY, _admin);
    }

    function grantFxHashIssuerRole(address _admin) public onlyAdmin {
        AccessControl.grantRole(LibAdmin.FXHASH_ISSUER, _admin);
    }

    function revokeFxHashIssuerRole(address _admin) public onlyAdmin {
        AccessControl.revokeRole(LibAdmin.FXHASH_ISSUER, _admin);
    }

    // Helper functions

    function isRequestedVariant(TokenKey memory tokenKey) private view returns (bool) {
        return (seeds[getTokenKey(tokenKey.issuer, tokenKey.id)].chain_seed != 0x00);
    }

    function getTokenKey(address issuer, uint256 id) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(issuer, id));
    }

}
