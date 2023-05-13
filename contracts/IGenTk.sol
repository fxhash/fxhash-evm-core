// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./lib-part/LibPart.sol";
import "./GenTkProject.sol";

interface IGenTk {
    function assignMetadata(uint256 tokenId, string memory newURI) external;
    function setGenTkProject(GenTkProject newGenTkProject) external;
    function getGenTkProject() external view returns (GenTkProject);
    function getDefaultURI() external view returns (string memory);
    function setDefaultURI(string memory _defaultURI) external;
    function mintGenTks(address to, uint256 projectId, uint256 iteration) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}