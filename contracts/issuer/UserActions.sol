// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibUserActions.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract UserActions is EIP712 {
    mapping(address => LibUserActions.UserAction) public userActions;

    constructor() EIP712("UserActions", "1") {}

    function getUserActions(
        address addr
    ) external view returns (LibUserActions.UserAction memory) {
        return userActions[addr];
    }

    function setLastIssuerMinted(
        address addr,
        address issuer,
        bytes calldata signature
    ) external {
        require(msg.sender == issuer, "Caller not Issuer");
        require(
            verifySignature(
                hashSetLastIssuerMinted(addr, issuer),
                signature,
                addr
            ),
            "Invalid signature"
        );
        userActions[addr].lastIssuerMinted = issuer;
        userActions[addr].lastIssuerMintedTime = block.timestamp;
    }

    function setLastMinted(
        address addr,
        address issuer,
        address tokenContract,
        uint256 tokenId,
        bytes calldata signature
    ) external {
        require(
            verifySignature(
                hashSetLastMinted(addr, issuer, tokenContract, tokenId),
                signature,
                addr
            ),
            "Invalid signature"
        );
        LibUserActions.UserAction storage userAction = userActions[addr];
        LibUserActions.MintedToken memory mintedToken = LibUserActions
            .MintedToken({
                issuer: issuer,
                tokenContract: tokenContract,
                tokenId: tokenId
            });
        userAction.lastMintedTime = block.timestamp;
        userAction.lastMinted = mintedToken;
    }

    function resetLastIssuerMinted(
        address addr,
        address issuer,
        bytes calldata signature
    ) external {
        require(
            verifySignature(
                hashResetLastIssuerMinted(addr, issuer),
                signature,
                addr
            ),
            "Invalid signature"
        );
        LibUserActions.UserAction storage action = userActions[addr];
        if (issuer == action.lastIssuerMinted) {
            action.lastIssuerMintedTime = 0;
        }
    }

    function hashSetLastIssuerMinted(
        address addr,
        address issuer
    ) private view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        LibUserActions.SET_LAST_ISSUER_MINTED_HASH,
                        addr,
                        issuer
                    )
                )
            );
    }

    function hashSetLastMinted(
        address addr,
        address issuer,
        address tokenContract,
        uint256 tokenId
    ) private view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        LibUserActions.SET_LAST_MINTED_HASH,
                        addr,
                        issuer,
                        tokenContract,
                        tokenId
                    )
                )
            );
    }

    function hashResetLastIssuerMinted(
        address addr,
        address issuer
    ) private view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        LibUserActions.RESET_LAST_ISSUER_MINTED_HASH,
                        addr,
                        issuer
                    )
                )
            );
    }

    function verifySignature(
        bytes32 data,
        bytes calldata signature,
        address caller
    ) private view returns (bool) {
        address signer = ECDSA.recover(data, signature);
        return signer == caller;
    }
}
