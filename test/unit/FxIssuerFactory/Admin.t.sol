// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxIssuerFactory/FxIssuerFactoryTest.t.sol";

contract Admin is FxIssuerFactoryTest {
    function testSetConfig() public {
        configInfo.feeShare = CONFIG_FEE_SHARE;
        configInfo.lockTime = CONFIG_LOCK_TIME;
        configInfo.defaultMetadata = CONFIG_DEFAULT_METADATA;
        vm.prank(admin);
        fxIssuerFactory.setConfig(configInfo);
        (feeShare, lockTime, defaultMetadata) = fxIssuerFactory.configInfo();
        assertEq(feeShare, configInfo.feeShare);
        assertEq(lockTime, configInfo.lockTime);
        assertEq(defaultMetadata, configInfo.defaultMetadata);
    }

    function testSetImplementation() public {
        vm.prank(admin);
        fxIssuerFactory.setImplementation(address(fxGenArt721));
        assertEq(fxIssuerFactory.implementation(), address(fxGenArt721));
    }
}
