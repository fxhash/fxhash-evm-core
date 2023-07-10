// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/interfaces/IModerationIssuer.sol";
import "contracts/interfaces/IAllowMint.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "contracts/libs/LibUserActions.sol";

contract AllowMint is IAllowMint, Ownable {
    address private issuerMod;

    constructor(address _issuerMod, address _admin) {
        issuerMod = _issuerMod;
        transferOwnership(_admin);
    }

    function updateIssuerModerationContract(
        address _address
    ) external onlyOwner {
        issuerMod = _address;
    }

    function isAllowed(address tokenContract) external view returns (bool) {
        // Get the state from the token moderation contract
        uint256 state = IModerationIssuer(issuerMod).issuerState(tokenContract);
        require(state < 2, "TOKEN_MODERATED");
        return true;
    }
}
