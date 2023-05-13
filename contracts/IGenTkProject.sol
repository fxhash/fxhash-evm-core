// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./lib-part/LibPart.sol";
import "./GenTk.sol";

interface IGenTkProject {
    struct Project {
        uint256 editions;
        uint256 price;
        uint256 openingTime;
        uint256 availableSupply;
        uint256 royaltiesBPs;
    }

    function getGenTk() external view returns (GenTk);
    function setGenTk(GenTk _genTk) external;
    function createProject(
        uint256 editions,
        uint256 price,
        uint256 openingTime,
        uint256 royaltiesBPs,
        string calldata projectURI,
        LibPart.Part[] memory _royalties
    ) external;
    function mint(uint256 genTkProjectId) external payable;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
