// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "contracts/libs/LibReserve.sol";
import "contracts/libs/LibRoyalty.sol";

library LibIssuer {
    struct OpenEditions {
        uint256 closingTime;
        bytes extra;
    }

    struct IssuerTokenData {
        uint256 balance;
        uint256 iterationsCount;
        bytes metadata;
        uint256 supply;
        OpenEditions openEditions;
        LibReserve.ReserveData[] reserves;
        LibRoyalty.RoyaltyData primarySplit;
        LibRoyalty.RoyaltyData royaltiesSplit;
        IssuerTokenInfo info;
    }

    struct IssuerTokenInfo {
        uint256[] tags;
        bool enabled;
        uint256 lockedSeconds;
        uint256 timestampMinted;
        bool lockPriceForReserves;
        bool hasTickets;
        address author;
        uint256 pricingId;
        uint256 codexId;
        uint256 inputBytesSize;
    }

    function verifyIssuerUpdateable(
        IssuerTokenData memory issuerToken
    ) external view {
        if (issuerToken.openEditions.closingTime > 0) {
            require(
                block.timestamp < issuerToken.openEditions.closingTime,
                "OE_CLOSE"
            );
        } else {
            require(issuerToken.balance > 0, "NO_BLNC");
        }
    }
}
