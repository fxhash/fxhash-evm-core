// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Base64} from "openzeppelin/contracts/utils/Base64.sol";
import {LibIPFSEncoder} from "src/lib/LibIPFSEncoder.sol";
import {SSTORE2} from "sstore2/contracts/SSTORE2.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

import {IERC721Metadata} from "openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";
import {IONCHFSRenderer} from "src/interfaces/IONCHFSRenderer.sol";

import "src/utils/Constants.sol";

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
        (, , , , , string memory defaultURI, ) = IFxContractRegistry(contractRegistry).configInfo();
        string memory contractAddr = uint160(msg.sender).toHexString(20);
        return string.concat(defaultURI, contractAddr, METADATA_ENDPOINT);
    }

    /**
     * @inheritdoc IONCHFSRenderer
     */
    function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory) {
        (bytes memory baseCID, address onchainPointer, address minter, bytes32 seed, bytes memory fxParams) = abi
            .decode(_data, (bytes, address, address, bytes32, bytes));
        string memory baseURI = LibIPFSEncoder.encodeURL(bytes32(baseCID));
        bytes memory onchainData = SSTORE2.read(onchainPointer);
        (string memory description, bytes32 onchfsCID) = abi.decode(onchainData, (string, bytes32));
        string memory animationURL = getAnimationURL(onchfsCID, _tokenId, minter, seed, fxParams);
        return _renderJSON(msg.sender, _tokenId, description, baseURI, animationURL);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IONCHFSRenderer
     */
    function getAttributes(
        address _contractAddr,
        string memory _baseURI,
        uint256 _tokenId
    ) public view returns (string memory) {
        (, , , , , string memory defaultURI, ) = IFxContractRegistry(contractRegistry).configInfo();
        string memory contractAddr = uint160(_contractAddr).toHexString(20);
        string memory attributesURI = string.concat("/", _tokenId.toString(), ATTRIBUTES_ENDPOINT);
        return
            (bytes(_baseURI).length == 0)
                ? string.concat(defaultURI, contractAddr, attributesURI)
                : string.concat(_baseURI, attributesURI);
    }

    /**
     * @inheritdoc IONCHFSRenderer
     */
    function getExternalURL(address _contractAddr, uint256 _tokenId) public view returns (string memory) {
        (, , , , , , string memory externalURI) = IFxContractRegistry(contractRegistry).configInfo();
        string memory contractAddr = uint160(_contractAddr).toHexString(20);
        string memory metadataURI = string.concat("-", _tokenId.toString());
        return string.concat(externalURI, contractAddr, metadataURI);
    }

    /**
     * @inheritdoc IONCHFSRenderer
     */
    function getImageURL(
        address _contractAddr,
        string memory _baseURI,
        uint256 _tokenId
    ) public view returns (string memory) {
        (, , , , , string memory defaultURI, ) = IFxContractRegistry(contractRegistry).configInfo();
        string memory contractAddr = uint160(_contractAddr).toHexString(20);
        string memory imageURI = string.concat("/", _tokenId.toString(), THUMBNAIL_ENDPOINT);
        return
            (bytes(_baseURI).length == 0)
                ? string.concat(defaultURI, contractAddr, imageURI)
                : string.concat(_baseURI, imageURI);
    }

    /**
     * @inheritdoc IONCHFSRenderer
     */
    function getAnimationURL(
        bytes32 _onchfsCID,
        uint256 _tokenId,
        address _minter,
        bytes32 _seed,
        bytes memory _fxParams
    ) public pure returns (string memory) {
        string memory fxHash = string.concat(FX_HASH_QUERY, uint256(_seed).toHexString());
        string memory iteration = string.concat(ITERATION_QUERY, _tokenId.toString());
        string memory minter = string.concat(MINTER_QUERY, uint160(_minter).toHexString(20));
        string memory fxParams = string.concat(FX_PARAMS_QUERY, string(_fxParams));
        string memory queryParams = string.concat(fxHash, iteration, minter, fxParams);
        return string.concat(ONCHFS_PREFIX, uint256(_onchfsCID).toHexString(), queryParams);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Reconstructs JSON metadata of token onchain
     */
    function _renderJSON(
        address _contractAdrr,
        uint256 _tokenId,
        string memory _description,
        string memory _baseURI,
        string memory _animationURL
    ) internal view returns (string memory) {
        string memory name = string.concat(IERC721Metadata(_contractAdrr).name(), " #", _tokenId.toString());
        string memory symbol = IERC721Metadata(_contractAdrr).symbol();
        string memory externalURL = getExternalURL(msg.sender, _tokenId);
        string memory imageURL = getImageURL(msg.sender, string(_baseURI), _tokenId);
        string memory attributes = getAttributes(msg.sender, string(_baseURI), _tokenId);

        return
            string.concat(
                "data:application/json;base64,",
                Base64.encode(
                    abi.encodePacked(
                        string.concat(
                            '"name:"',
                            name,
                            '", "description:"',
                            _description,
                            '", "symbol:"',
                            symbol,
                            '", "version: 0.2"',
                            '", "externalURL:"',
                            externalURL,
                            '", "image":"',
                            imageURL,
                            '", "animation_url":"',
                            _animationURL,
                            '", "attributes":["',
                            attributes,
                            '"]}'
                        )
                    )
                )
            );
    }
}
