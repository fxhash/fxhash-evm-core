// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {MintPassGroup} from "contracts/mint-pass-group/MintPassGroup.sol";
import {ContentStore} from "contracts/scripty/dependencies/ethfs/ContentStore.sol";
import {ScriptyStorage} from "contracts/scripty/ScriptyStorage.sol";
import {ScriptyBuilder} from "contracts/scripty/ScriptyBuilder.sol";
import {ReserveWhitelist} from "contracts/reserve/ReserveWhitelist.sol";
import {ReserveMintPass} from "contracts/reserve/ReserveMintPass.sol";
import {ModerationToken} from "contracts/moderation/ModerationToken.sol";
import {ModerationUser} from "contracts/moderation/ModerationUser.sol";
import {ModerationTeam} from "contracts/moderation/ModerationTeam.sol";
import {UserActions} from "contracts/issuer/UserActions.sol";
import {AllowMint} from "contracts/allow-mint/AllowMint.sol";
import {AllowMintIssuer} from "contracts/allow-mint/AllowMintIssuer.sol";
import {PricingDutchAuction} from "contracts/pricing/PricingDutchAuction.sol";
import {PricingFixed} from "contracts/pricing/PricingFixed.sol";
import {Randomizer} from "contracts/randomizer/Randomizer.sol";
import {ReserveManager} from "contracts/issuer/ReserveManager.sol";
import {PricingManager} from "contracts/issuer/PricingManager.sol";
import {Issuer, IIssuer} from "contracts/issuer/Issuer.sol";
import {MintTicket} from "contracts/mint-ticket/MintTicket.sol";
import {GenTk} from "contracts/gentk/GenTk.sol";
import {OnChainTokenMetadataManager} from "contracts/issuer/OnChainTokenMetadataManager.sol";

contract IssuerTest is Test {
    address public admin = address(1);
    address public receiver = address(2);
    address public signer = address(3);
    address public treasury = address(4);
    address public addr1 = address(5);
    address public addr2 = address(6);
    address public addr3 = address(7);

    uint256[2] public authorizations = [10, 20];
    /// scripty
    ContentStore public contentStore;
    ScriptyStorage public scriptyStorage;
    ScriptyBuilder public scriptyBuilder;
    ReserveWhitelist public reserveWhitelist;
    ReserveMintPass public reserveMintPass;
    MintPassGroup public mintPassGroup;
    ModerationToken public moderationToken;
    ModerationTeam public moderationTeam;
    ModerationUser public moderationUser;
    UserActions public userActions;
    AllowMint public allowMint;
    PricingDutchAuction public pricingDA;
    PricingFixed public pricingFixed;
    Randomizer public randomizer;
    PricingManager public pricingManager;
    ReserveManager public reserveManager;
    AllowMintIssuer public allowMintIssuer;
    Issuer public issuer;
    MintTicket public mintTicket;
    GenTk public genTk;
    OnChainTokenMetadataManager public onchainMetadataManager;

    function setUp() public virtual {
        /// move this stuff to Script and import here
        contentStore = new ContentStore();
        scriptyStorage = new ScriptyStorage(address(contentStore));
        scriptyBuilder = new ScriptyBuilder();
        reserveWhitelist = new ReserveWhitelist();
        reserveMintPass = new ReserveMintPass();
        mintPassGroup = new MintPassGroup(
            10, /* maxPerToken */
            5, /* maxPerTokenPerProject */
            admin, /* signer (authorized caller)*/
            new address[](0) /* bypass array */
        );
        moderationToken = new ModerationToken(admin);
        moderationTeam = new ModerationTeam(admin);
        moderationUser = new ModerationUser(admin);
        userActions = new UserActions(admin);
        allowMint = new AllowMint(
            admin,
            address(moderationToken),
            address(userActions)
        );
        pricingDA = new PricingDutchAuction();
        pricingFixed = new PricingFixed();
        randomizer = new Randomizer(keccak256("seed"), keccak256("salt"));
        pricingManager = new PricingManager(admin);
        reserveManager = new ReserveManager(admin);
        allowMintIssuer = new AllowMintIssuer(
            admin,
            address(moderationUser),
            address(userActions)
        );
        issuer = new Issuer(IIssuer.Config(2500, 1000, 1000, ""), admin);
        mintTicket = new MintTicket(
            admin,
            address(issuer),
            address(randomizer)
        );
        onchainMetadataManager = new OnChainTokenMetadataManager(
            address(scriptyBuilder)
        );
        genTk = new GenTk(
            admin,
            signer,
            treasury,
            address(issuer),
            address(onchainMetadataManager)
        );
    }
}

contract MintIssuer is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract Mint is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract MintWithTicket is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract UpdateIssuer is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract UpdatePrice is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract Burn is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract BurnSupply is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract SetCodex is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract GetIssuer is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract RoyaltyInfo is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract PrimarySplitInfo is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}

contract SupportsInterfaces is IssuerTest {
    function test_True() public {
        assertTrue(true);
    }
}
