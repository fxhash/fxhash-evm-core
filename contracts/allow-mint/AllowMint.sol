// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/interfaces/IModerationToken.sol";
import "contracts/abstract/admin/FxHashAdminVerify.sol";

contract AllowMint is FxHashAdminVerify {
    IModerationToken public tokenModContract;
    address public issuerContract;

    constructor(
        address _admin,
        address _tokenModContract,
        address _issuerContract
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(FXHASH_ADMIN, _admin);
        tokenModContract = IModerationToken(_tokenModContract);
        issuerContract = _issuerContract;
    }

    function updateTokenModerationContract(
        address _address
    ) external onlyAdmin {
        tokenModContract = IModerationToken(_address);
    }

    function updateIssuerContract(address _address) external onlyAdmin {
        issuerContract = _address;
    }

    function isAllowed(
        address addr,
        uint256 timestamp,
        uint256 id
    ) external view returns (bool) {
        // Get the state from the token moderation contract
        uint256 state = tokenModContract.tokenState(id);
        require(state < 2, "TOKEN_MODERATED");
        //TODO: needs to be fixed when issuer will be ready
        // Prevent batch minting on any token
        // UserActions memory userActions = IIssuerContract(
        //     self.data.issuerContract
        // ).getUserActions(addr);
        // require(timestamp - userActions.lastMintedTime > 0, "NO_BATCH_MINTING");
        require(
            SignedMath.abs(int256(timestamp) - int256(block.timestamp)) > 0,
            "NO_BATCH_MINTING"
        );
        return true;
    }
}
