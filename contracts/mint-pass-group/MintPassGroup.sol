// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "contracts/libs/LibAdmin.sol";
import "hardhat/console.sol";

contract MintPassGroup is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;
    struct TokenRecord {
        uint256 minted;
        uint256 levelConsumed;
        address consumer;
    }

    struct Pass {
        bytes payload;
        bytes signature;
    }

    struct Payload {
        string token;
        uint256 project;
        address addr;
    }

    uint256 public maxPerToken;
    uint256 public maxPerTokenPerProject;
    address public signer;
    EnumerableSet.AddressSet private bypass;
    mapping(string => TokenRecord) public tokens;
    mapping(bytes32 => uint256) public projects;

    constructor(
        uint256 _maxPerToken,
        uint256 _maxPerTokenPerProject,
        address _signer,
        address[] memory _bypass
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, address(bytes20(_signer)));
        _setupRole(LibAdmin.FXHASH_ADMIN, address(bytes20(_signer)));
        maxPerToken = _maxPerToken;
        maxPerTokenPerProject = _maxPerTokenPerProject;
        signer = _signer;
        for (uint256 i = 0; i < _bypass.length; i++) {
            EnumerableSet.add(bypass, _bypass[i]);
        }
    }

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

    function consumePass(Pass calldata _params) external {
        Payload memory payload = decodePayload(_params.payload);
        bytes32 projectHash = getProjectHash(payload.token, payload.project);
        require(
            EnumerableSet.contains(bypass, _msgSender()) ||
                _msgSender() == payload.addr,
            "PASS_INVALID_ADDRESS"
        );
        //require(
        //    checkSignature(_params.signature, _params.payload),
        //    "PASS_INVALID_SIGNATURE"
        //);
        if (tokens[payload.token].minted > 0) {
            TokenRecord storage tokenRecord = tokens[payload.token];
            require(
                payload.addr == tokenRecord.consumer,
                "WRONG_PASS_CONSUMER"
            );
            if (maxPerToken != 0) {
                require(
                    tokenRecord.minted < maxPerToken,
                    "PASS_TOKEN_MAX_CONSUMED"
                );
            }
            tokenRecord.minted += 1;
            if (maxPerTokenPerProject != 0) {
                require(
                    projects[projectHash] < maxPerTokenPerProject,
                    "PASS_TOKEN_MAX_PROJECT_CONSUMED"
                );
            }
            projects[projectHash] += 1;
            tokenRecord.levelConsumed = block.number;
        } else {
            tokens[payload.token].minted = 1;
            tokens[payload.token].levelConsumed = block.number;
            tokens[payload.token].consumer = payload.addr;
            projects[projectHash] = 1;
        }
    }

    function setConstraints(
        uint256 _maxPerToken,
        uint256 _maxPerTokenPerProject
    ) external onlyFxHashAdmin {
        maxPerToken = _maxPerToken;
        maxPerTokenPerProject = _maxPerTokenPerProject;
    }

    function setBypass(address[] memory _addresses) external onlyFxHashAdmin {
        for (uint256 i = 0; i < _addresses.length; i++) {
            EnumerableSet.add(bypass, _addresses[i]);
        }
    }

    function isPassValid(bytes calldata _payload) external view {
        Payload memory payload = decodePayload(_payload);
        TokenRecord memory token = tokens[payload.token];
        console.log(msg.sender);
        console.log(payload.addr);
        require(token.minted > 0, "PASS_NOT_CONSUMED");
        require(token.levelConsumed == block.number, "PASS_CONSUMED_PAST");
        require(
            EnumerableSet.contains(bypass, msg.sender) ||
                msg.sender == payload.addr,
            "PASS_INVALID_ADDRESS"
        );
        require(payload.addr == token.consumer, "WRONG_PASS_CONSUMER");
        //require(checkSignature(_params.payload, _params.signature), "PASS_INVALID_SIGNATURE");
    }

    function decodePayload(
        bytes memory _payload
    ) private pure returns (Payload memory) {
        Payload memory decodedData = abi.decode(_payload, (Payload));
        if (decodedData.addr == address(0)) {
            revert("PASS_INVALID_PAYLOAD");
        }
        return decodedData;
    }

    function getProjectHash(
        string memory token,
        uint256 project
    ) public pure returns (bytes32) {
        bytes32 tokenHash = keccak256(bytes(token));
        bytes32 projectHash = bytes32(project);
        return keccak256(abi.encodePacked(tokenHash, projectHash));
    }

    function checkSignature(
        bytes memory _signature,
        bytes memory _payload
    ) private view returns (bool) {
        bytes32 payloadHash = keccak256(_payload);
        address recovered = ECDSA.recover(
            ECDSA.toEthSignedMessageHash(payloadHash),
            _signature
        );
        return signer == recovered;
    }

    function getBypass() public view returns (address[] memory) {
        return bypass.values();
    }
}
