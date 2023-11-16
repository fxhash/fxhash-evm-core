// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LibIPFSEncoder} from "src/lib/LibIPFSEncoder.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

import {GenArtInfo, MetadataInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";
import {IIPFSRenderer} from "src/interfaces/IIPFSRenderer.sol";

/**
 * @title IPFSRenderer
 * @author fx(hash)
 * @dev See the documentation in {IIPFSRenderer}
 */
contract IPFSRenderer is IIPFSRenderer {
    using Strings for uint160;
    using Strings for uint256;

    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IIPFSRenderer
     */
    address public immutable contractRegistry;

    /*//////////////////////////////////////////////////////////////////////////
                                  CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Initializes FxContractRegistry
     */
    constructor(address _contractRegistry) {
        contractRegistry = _contractRegistry;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IIPFSRenderer
     */
    function contractURI() external view returns (string memory) {
        (, , string memory defaultURI) = IFxContractRegistry(contractRegistry).configInfo();
        string memory contractAddr = uint160(msg.sender).toHexString(20);
        return string.concat(defaultURI, contractAddr, "/metadata.json");
    }

    /**
     * @inheritdoc IIPFSRenderer
     */
    function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory) {
        (MetadataInfo memory metadataInfo, ) = abi.decode(_data, (MetadataInfo, GenArtInfo));
        string memory baseURI = LibIPFSEncoder.encodeURL(bytes32(metadataInfo.baseURI));
        return getMetadataURI(msg.sender, baseURI, _tokenId);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IIPFSRenderer
     */
    function getMetadataURI(
        address _contractAddr,
        string memory _baseURI,
        uint256 _tokenId
    ) public view returns (string memory) {
        (, , string memory defaultURI) = IFxContractRegistry(contractRegistry).configInfo();
        string memory contractAddr = uint160(_contractAddr).toHexString(20);
        string memory jsonMetadataURI = string.concat("/", _tokenId.toString(), "/metadata.json");
        return
            (bytes(_baseURI).length == 0)
                ? string.concat(defaultURI, contractAddr, jsonMetadataURI)
                : string.concat(_baseURI, jsonMetadataURI);
    }
}
