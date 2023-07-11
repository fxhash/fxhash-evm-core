// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

library LibCodex {
    struct CodexData {
        uint256 entryType;
        address author;
        bool locked;
        address issuer;
        bytes[] value;
    }

    struct CodexInput {
        uint256 inputType;
        bytes value;
        uint256 codexId;
        address issuer;
    }
}
