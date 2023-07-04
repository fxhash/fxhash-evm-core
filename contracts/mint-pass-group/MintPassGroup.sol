// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "contracts/abstract/admin/AuthorizedCaller.sol";

contract MintPassGroup is AuthorizedCaller {
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

    event PassConsumed(address addr, string token, uint256 project);

    constructor(
        uint256 _maxPerToken,
        uint256 _maxPerTokenPerProject,
        address _signer,
        address[] memory _bypass
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _signer);
        _setupRole(AUTHORIZED_CALLER, _signer);
        maxPerToken = _maxPerToken;
        maxPerTokenPerProject = _maxPerTokenPerProject;
        signer = _signer;
        for (uint256 i = 0; i < _bypass.length; i++) {
            EnumerableSet.add(bypass, _bypass[i]);
        }
    }

    function consumePass(bytes calldata _params) external {
        Pass memory pass = decodePass(_params);
        Payload memory payload = decodePayload(pass.payload);
        bytes32 projectHash = getProjectHash(payload.token, payload.project);
        require(
            EnumerableSet.contains(bypass, tx.origin) || tx.origin == payload.addr,
            "PASS_INVALID_ADDRESS"
        );
        require(checkSignature(pass.signature, pass.payload), "PASS_INVALID_SIGNATURE");
        if (tokens[payload.token].minted > 0) {
            TokenRecord storage tokenRecord = tokens[payload.token];
            require(payload.addr == tokenRecord.consumer, "WRONG_PASS_CONSUMER");
            if (maxPerToken != 0) {
                require(tokenRecord.minted < maxPerToken, "PASS_TOKEN_MAX_CONSUMED");
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
            TokenRecord storage tokenRecord = tokens[payload.token];
            tokenRecord.minted = 1;
            tokenRecord.levelConsumed = block.number;
            tokenRecord.consumer = payload.addr;
            projects[projectHash] = 1;
        }
        emit PassConsumed(payload.addr, payload.token, payload.project);
    }

    function setConstraints(uint256 _maxPerToken, uint256 _maxPerTokenPerProject)
        external
        onlyAuthorizedCaller
    {
        maxPerToken = _maxPerToken;
        maxPerTokenPerProject = _maxPerTokenPerProject;
    }

    function setBypass(address[] memory _addresses) external onlyAuthorizedCaller {
        for (uint256 i = 0; i < _addresses.length; i++) {
            EnumerableSet.add(bypass, _addresses[i]);
        }
    }

    function isPassValid(bytes calldata _payload) external view {
        Pass memory pass = decodePass(_payload);
        Payload memory payload = decodePayload(pass.payload);
        TokenRecord storage token = tokens[payload.token];
        require(token.minted > 0, "PASS_NOT_CONSUMED");
        require(token.levelConsumed == block.number, "PASS_CONSUMED_PAST");
        require(
            EnumerableSet.contains(bypass, tx.origin) || tx.origin == payload.addr,
            "PASS_INVALID_ADDRESS"
        );
        require(payload.addr == token.consumer, "WRONG_PASS_CONSUMER");
        require(checkSignature(pass.payload, pass.signature), "PASS_INVALID_SIGNATURE");
    }

    function getProjectHash(string memory token, uint256 project) public pure returns (bytes32) {
        bytes32 tokenHash = keccak256(bytes(token));
        bytes32 projectHash = bytes32(project);
        return keccak256(abi.encodePacked(tokenHash, projectHash));
    }

    function decodePayload(bytes memory _payload) private pure returns (Payload memory) {
        Payload memory decodedData = abi.decode(_payload, (Payload));
        if (decodedData.addr == address(0)) {
            revert("PASS_INVALID_PAYLOAD");
        }
        return decodedData;
    }

    function decodePass(bytes memory _payload) private pure returns (Pass memory) {
        Pass memory decodedData = abi.decode(_payload, (Pass));
        if (decodedData.payload.length == 0) {
            revert("PASS_INVALID_PAYLOAD");
        }
        if (decodedData.signature.length == 0) {
            revert("PASS_INVALID_SIGNATURE");
        }
        return decodedData;
    }

    function checkSignature(bytes memory _signature, bytes memory _payload)
        private
        view
        returns (bool)
    {
        bytes32 payloadHash = keccak256(_payload);
        address recovered = ECDSA.recover(ECDSA.toEthSignedMessageHash(payloadHash), _signature);
        return signer == recovered;
    }

    function getBypass() public view returns (address[] memory) {
        return bypass.values();
    }
}
