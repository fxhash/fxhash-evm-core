// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";
import {IONCHFSRenderer} from "src/interfaces/IONCHFSRenderer.sol";

import {METADATA_ENDPOINT} from "src/utils/Constants.sol";

/**
 * @title ONCHFSRenderer
 * @author fx(hash)
 * @dev See the documentation in {IONCHFSRenderer}
 */
contract ONCHFSRenderer is IONCHFSRenderer {
    using Strings for uint160;
    using Strings for uint256;

    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IONCHFSRenderer
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
     * @inheritdoc IONCHFSRenderer
     */
    function contractURI() external view returns (string memory) {
        (, , , , , string memory defaultURI) = IFxContractRegistry(contractRegistry).configInfo();
        string memory contractAddr = uint160(msg.sender).toHexString(20);
        return string.concat(defaultURI, contractAddr, METADATA_ENDPOINT);
    }

    /**
     * @inheritdoc IONCHFSRenderer
     */
    function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory) {
        (bytes memory baseURI, , , ) = abi.decode(_data, (bytes, address, bytes32, bytes));
        return getMetadataURI(msg.sender, string(baseURI), _tokenId);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IONCHFSRenderer
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
