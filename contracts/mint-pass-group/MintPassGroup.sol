// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract MintPassGroup is Ownable, EIP712 {
    bytes32 public constant PAYLOAD_TYPE_HASH =
        keccak256("Payload(string token,address project,address addr)");

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
        address project;
        address addr;
    }

    uint256 private maxPerToken;
    uint256 private maxPerTokenPerProject;
    address private signer;
    address private reserveMintPass;
    EnumerableSet.AddressSet private bypass;
    mapping(string => TokenRecord) private tokens;
    mapping(bytes32 => uint256) private projects;

    event PassConsumed(address addr, string token, address project);

    constructor(
        uint256 _maxPerToken,
        uint256 _maxPerTokenPerProject,
        address _signer,
        address _reserveMintPass,
        address[] memory _bypass
    ) EIP712("MintPassGroup", "1") {
        maxPerToken = _maxPerToken;
        maxPerTokenPerProject = _maxPerTokenPerProject;
        signer = _signer;
        reserveMintPass = _reserveMintPass;
        for (uint256 i = 0; i < _bypass.length; i++) {
            EnumerableSet.add(bypass, _bypass[i]);
        }
        transferOwnership(_signer);
    }

    modifier onlyReserveMintPass() {
        require(msg.sender == reserveMintPass, "Caller not Reserve Mint Pass");
        _;
    }

    function consumePass(
        bytes calldata _params,
        address _caller
    ) external onlyReserveMintPass {
        Pass memory pass = decodePass(_params);
        Payload memory payload = decodePayload(pass.payload);
        bytes32 projectHash = getProjectHash(payload.token, payload.project);
        require(
            EnumerableSet.contains(bypass, msg.sender) ||
                _caller == payload.addr,
            "PASS_INVALID_ADDRESS"
        );
        require(
            checkSignature(pass.signature, payload),
            "PASS_INVALID_SIGNATURE"
        );
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
            TokenRecord storage tokenRecord = tokens[payload.token];
            tokenRecord.minted = 1;
            tokenRecord.levelConsumed = block.number;
            tokenRecord.consumer = payload.addr;
            projects[projectHash] = 1;
        }
        emit PassConsumed(payload.addr, payload.token, payload.project);
    }

    function setConstraints(
        uint256 _maxPerToken,
        uint256 _maxPerTokenPerProject
    ) external onlyOwner {
        maxPerToken = _maxPerToken;
        maxPerTokenPerProject = _maxPerTokenPerProject;
    }

    function setBypass(address[] memory _addresses) external onlyOwner {
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
            EnumerableSet.contains(bypass, msg.sender) ||
                msg.sender == payload.addr,
            "PASS_INVALID_ADDRESS"
        );
        require(payload.addr == token.consumer, "WRONG_PASS_CONSUMER");
        require(
            checkSignature(pass.signature, payload),
            "PASS_INVALID_SIGNATURE"
        );
    }

    function getProjectHash(
        string memory token,
        address project
    ) public pure returns (bytes32) {
        bytes32 tokenHash = keccak256(bytes(token));
        return keccak256(abi.encodePacked(tokenHash, project));
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

    function decodePass(
        bytes memory _payload
    ) private pure returns (Pass memory) {
        Pass memory decodedData = abi.decode(_payload, (Pass));
        if (decodedData.payload.length == 0) {
            revert("PASS_INVALID_PAYLOAD");
        }
        if (decodedData.signature.length == 0) {
            revert("PASS_INVALID_SIGNATURE");
        }
        return decodedData;
    }

    function checkSignature(
        bytes memory _signature,
        Payload memory _payload
    ) private view returns (bool) {
        bytes32 payloadHash = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    PAYLOAD_TYPE_HASH,
                    _payload.token,
                    _payload.project,
                    _payload.addr
                )
            )
        );
        address recovered = ECDSA.recover(payloadHash, _signature);
        return signer == recovered;
    }

    function getBypass() public view returns (address[] memory) {
        return bypass.values();
    }
}
