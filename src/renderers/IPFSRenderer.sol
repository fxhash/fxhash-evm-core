// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LibIPFSEncoder} from "src/lib/LibIPFSEncoder.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

import {GenArtInfo, MetadataInfo} from "src/interfaces/IFxGenArt721.sol";
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
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IIPFSRenderer
     */
    function contractURI(string memory _defaultURI) external view returns (string memory) {
        string memory contractAddr = uint160(msg.sender).toHexString(20);
        return string.concat(_defaultURI, contractAddr, "/metadata.json");
    }

    /**
     * @inheritdoc IIPFSRenderer
     */
    function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory) {
        (string memory defaultURI, MetadataInfo memory metadataInfo, ) = abi.decode(
            _data,
            (string, MetadataInfo, GenArtInfo)
        );
        string memory baseURI = LibIPFSEncoder.encodeURL(bytes32(metadataInfo.baseURI));
        return metadataURI(defaultURI, baseURI, _tokenId);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IIPFSRenderer
     */
    function metadataURI(
        string memory _defaultURI,
        string memory _baseURI,
        uint256 _tokenId
    ) public view returns (string memory) {
        string memory contractAddr = uint160(address(this)).toHexString(20);
        string memory jsonMetadataURI = string.concat("/", _tokenId.toString(), "/metadata.json");
        return
            (bytes(_baseURI).length == 0)
                ? string.concat(_defaultURI, contractAddr, jsonMetadataURI)
                : string.concat(_baseURI, jsonMetadataURI);
    }
}
