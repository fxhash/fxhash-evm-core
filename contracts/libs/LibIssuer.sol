// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibReserve.sol";
import "contracts/libs/LibRoyalty.sol";

library LibIssuer {
    struct OpenEditions {
        uint256 closingTime;
        bytes extra;
    }

    struct IssuerData {
        uint256 balance;
        uint96 iterationsCount;
        bytes metadata;
        uint256 supply;
        OpenEditions openEditions;
        bytes reserves;
        LibRoyalty.RoyaltyData primarySplit;
        LibRoyalty.RoyaltyData royaltiesSplit;
        IssuerInfo info;
        bytes onChainData;
    }

    struct IssuerInfo {
        uint256[] tags;
        bool enabled;
        uint256 lockedSeconds;
        uint256 timestampMinted;
        bool lockPriceForReserves;
        bool hasTickets;
        uint256 pricingId;
        uint256 codexId;
        uint256 inputBytesSize;
    }

    function verifyIssuerUpdateable(IssuerData memory issuerToken) external view {
        if (issuerToken.openEditions.closingTime > 0) {
            require(block.timestamp < issuerToken.openEditions.closingTime, "OE_CLOSE");
        } else {
            require(issuerToken.balance > 0, "NO_BLNC");
        }
    }
}
