// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibIPFSEncoder} from "src/lib/LibIPFSEncoder.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";
import {IIPFSRenderer} from "src/interfaces/IIPFSRenderer.sol";

import {METADATA_ENDPOINT} from "src/utils/Constants.sol";

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
        (, , , , , string memory defaultURI) = IFxContractRegistry(contractRegistry).configInfo();
        string memory contractAddr = uint160(msg.sender).toHexString(20);
        return string.concat(defaultURI, contractAddr, METADATA_ENDPOINT);
    }

    /**
     * @inheritdoc IIPFSRenderer
     */
    function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory) {
        (bytes memory baseCID, , , ) = abi.decode(_data, (bytes, address, bytes32, bytes));
        string memory baseURI = LibIPFSEncoder.encodeURL(bytes32(baseCID));
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
        (, , , , , string memory defaultURI) = IFxContractRegistry(contractRegistry).configInfo();
        string memory contractAddr = uint160(_contractAddr).toHexString(20);
        string memory metadataURI = string.concat("/", _tokenId.toString(), METADATA_ENDPOINT);
        return
            (bytes(_baseURI).length == 0)
                ? string.concat(defaultURI, contractAddr, metadataURI)
                : string.concat(_baseURI, metadataURI);
    }
}
