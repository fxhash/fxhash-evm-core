// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "contracts/interfaces/IFxHashIssuer.sol";

contract FxHashIssuer is IFxHashIssuer {
    function getUserActions(
        address addr
    ) external view override returns (UserActions memory) {}

    function getTokenPrimarySplit(
        uint256 projectId,
        uint256 amount
    ) external override returns (address receiver, uint256 royaltyAmount) {
        return (address(0), 1000);
    }
}
