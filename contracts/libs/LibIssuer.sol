// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibReserve.sol";
import "contracts/libs/LibRoyalty.sol";

library LibIssuer {
    struct OpenEditions {
        uint256 closingTime;
        bytes extra;
    }

    struct IssuerTokenData {
        address author;
        uint256 balance;
        uint256 iterationsCount;
        uint256 codexId;
        bytes metadata;
        uint256 inputBytesSize;
        uint256 supply;
        OpenEditions openEditions;
        bool hasTickets;
        LibReserve.ReserveData[] reserves;
        uint256 pricingId;
        bool lockPriceForReserves;
        LibRoyalty.RoyaltyData primarySplit;
        LibRoyalty.RoyaltyData royaltiesSplit;
        bool enabled;
        uint256 timestampMinted;
        uint256 lockedSeconds;
        uint256[] tags;
    }

    function verifyIssuerUpdateable(
        IssuerTokenData storage issuerToken
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
