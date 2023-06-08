// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "contracts/libs/lib-admin/LibAdmin.sol";
import "hardhat/console.sol";

contract MintPassGroup is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;
    struct TokenRecord {
        uint256 minted;
        mapping(uint256 => uint256) projects;
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

    uint256 private maxPerToken;
    uint256 private maxPerTokenPerProject;
    address private signer;
    EnumerableSet.AddressSet private bypass;
    mapping(string => TokenRecord) public tokens;

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
        require(AccessControl.hasRole(AccessControl.DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not an admin");
        _;
    }

    modifier onlyFxHashAdmin() {
        require(AccessControl.hasRole(LibAdmin.FXHASH_ADMIN, _msgSender()), "Caller is not a FxHash admin");
        _;
    }

    function consumePass(Pass calldata _params) external {
        Payload memory payload = decodePayload(_params);
        require(
            EnumerableSet.contains(bypass, msg.sender) || msg.sender == payload.addr,
            "PASS_INVALID_ADDRESS"
        );
        require(
            checkSignature(_params.signature, _params.payload),
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
                    tokenRecord.projects[payload.project] <
                        maxPerTokenPerProject,
                    "PASS_TOKEN_MAX_PROJECT_CONSUMED"
                );
            }
            tokenRecord.projects[payload.project] += 1;
            tokenRecord.levelConsumed = block.number;
        } else {
            tokens[payload.token].minted = 1;
            tokens[payload.token].levelConsumed = block.number;
            tokens[payload.token].consumer = payload.addr;
            tokens[payload.token].projects[payload.project] = 1;
            console.log(tokens[payload.token].minted);
        }
    }

    function setConstraints(uint256 _maxPerToken, uint256 _maxPerTokenPerProject) onlyFxHashAdmin
        external
    {
        maxPerToken = _maxPerToken;
        maxPerTokenPerProject = _maxPerTokenPerProject;
    }

    function setBypass(address[] memory _addresses) external onlyFxHashAdmin{
        for (uint256 i = 0; i < _addresses.length; i++) {
            EnumerableSet.add(bypass, _addresses[i]);
        }
    }

    function isPassValid(Pass memory _params) external view returns (bool) {
        Payload memory payload = decodePayload(_params);
        require(
            tokens[payload.token].levelConsumed == block.number,
            "PASS_CONSUMED_PAST"
        );
        require(
            EnumerableSet.contains(bypass, msg.sender) || msg.sender == payload.addr,
            "PASS_INVALID_ADDRESS"
        );
        require(
            checkSignature(_params.signature, _params.payload),
            "PASS_INVALID_SIGNATURE"
        );
        require(
            payload.addr == tokens[payload.token].consumer,
            "WRONG_PASS_CONSUMER"
        );
        return true;
    }

    function decodePayload(Pass memory _params) private pure returns (Payload memory) {
        Payload memory decodedData = abi.decode(_params.payload, (Payload));
        if(decodedData.addr == address(0)){
            revert("PASS_INVALID_PAYLOAD");
        }
        return decodedData;
    }

    function checkSignature(
        bytes memory _signature,
        bytes memory _payload
    ) private view returns (bool) {
        bytes32 payloadHash = keccak256(_payload);
        address recovered = ECDSA.recover(ECDSA.toEthSignedMessageHash(payloadHash), _signature);
        return signer == recovered;
    }
}
