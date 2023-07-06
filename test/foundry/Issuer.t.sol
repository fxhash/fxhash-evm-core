// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {MintPassGroup} from "contracts/mint-pass-group/MintPassGroup.sol";
import {ContentStore} from "contracts/scripty/dependencies/ethfs/ContentStore.sol";
import {ScriptyStorage} from "contracts/scripty/ScriptyStorage.sol";
import {ScriptyBuilder} from "contracts/scripty/ScriptyBuilder.sol";

contract IssuerTest is Test {
    bytes32 public adminPk =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    bytes32 public fxHashAdminPk =
        0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    bytes32 public user1Pk =
        0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
    bytes32 public user2Pk =
        0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6;

    address public admin = vm.addr(uint256(adminPk));
    address public fxHashAdmin = vm.addr(uint256(fxHashAdminPk));
    address public user1 = vm.addr(uint256(user1Pk));
    address public user2 = vm.addr(uint256(user2Pk));

    uint256[2] public authorizations = [10, 20];
    /// scripty
    ContentStore public contentStore;
    ScriptyStorage public scriptyStorage;
    ScriptyBuilder public scriptyBuilder;

    function setUp() public virtual {
        contentStore = new ContentStore();
        scriptyStorage = new ScriptyStorage(address(contentStore));
        scriptyBuilder = new ScriptyBuilder();
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
