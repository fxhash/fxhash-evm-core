// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "script/utils/Constants.sol";
import "src/utils/Constants.sol";
import "test/utils/Constants.sol";

import {HTMLRequest, HTMLTagType, HTMLTag} from "scripty.sol/contracts/scripty/core/ScriptyStructs.sol";
import {MintInfo, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";

library ConfigureLib {
    function splits(
        address _creator,
        address _admin,
        address[] storage _accounts,
        uint256[] storage _allocations
    ) internal virtual {
        if (_creator < _admin) {
            _accounts.push(_creator);
            _accounts.push(_admin);
            _allocations.push(CREATOR_ALLOCATION);
            _allocations.push(ADMIN_ALLOCATION);
        } else {
            _accounts.push(_admin);
            _accounts.push(_creator);
            _allocations.push(ADMIN_ALLOCATION);
            _allocations.push(CREATOR_ALLOCATION);
        }
    }

    function royalties(
        address _admin,
        address _creator,
        address payable[] storage _receivers,
        uint256[] storage _points
    ) internal virtual {
        _receivers.push(payable(_admin));
        _receivers.push(payable(_creator));
        _points.push(ROYALTY_BPS);
        _points.push(ROYALTY_BPS * 2);
    }

    function scripty(
        address _ethFSFileStorage,
        address _scriptyBuilderV2,
        address _scriptyStorageV2,
        HTMLRequest storage _animation,
        HTMLTag[] storage _headTags,
        HTMLTag[] storage _bodyTags,
        bytes storage _onchainData
    ) internal virtual {
        if (block.chainid == SEPOLIA) {
            _ethFSFileStorage = SEPOLIA_ETHFS_FILE_STORAGE;
            _scriptyBuilderV2 = SEPOLIA_SCRIPTY_BUILDER_V2;
            _scriptyStorageV2 = SEPOLIA_SCRIPTY_STORAGE_V2;
        } else {
            _ethFSFileStorage = GOERLI_ETHFS_FILE_STORAGE;
            _scriptyBuilderV2 = GOERLI_SCRIPTY_BUILDER_V2;
            _scriptyStorageV2 = GOERLI_SCRIPTY_STORAGE_V2;
        }

        _headTags.push(
            HTMLTag({
                name: CSS_CANVAS_SCRIPT,
                contractAddress: _ethFSFileStorage,
                contractData: bytes(""),
                tagType: HTMLTagType.useTagOpenAndClose,
                tagOpen: TAG_OPEN,
                tagClose: TAG_CLOSE,
                tagContent: bytes("")
            })
        );

        _bodyTags.push(
            HTMLTag({
                name: P5_JS_SCRIPT,
                contractAddress: _ethFSFileStorage,
                contractData: bytes(""),
                tagType: HTMLTagType.scriptGZIPBase64DataURI,
                tagOpen: bytes(""),
                tagClose: bytes(""),
                tagContent: bytes("")
            })
        );

        _bodyTags.push(
            HTMLTag({
                name: GUNZIP_JS_SCRIPT,
                contractAddress: _ethFSFileStorage,
                contractData: bytes(""),
                tagType: HTMLTagType.scriptBase64DataURI,
                tagOpen: bytes(""),
                tagClose: bytes(""),
                tagContent: bytes("")
            })
        );

        _bodyTags.push(
            HTMLTag({
                name: POINTS_AND_LINES_SCRIPT,
                contractAddress: _scriptyStorageV2,
                contractData: bytes(""),
                tagType: HTMLTagType.script,
                tagOpen: bytes(""),
                tagClose: bytes(""),
                tagContent: bytes("")
            })
        );

        _animation.headTags = _headTags;
        _animation.bodyTags = _bodyTags;
        _onchainData = abi.encode(_animation);
    }

    function state(uint256 _amount, uint256 _price, uint256 _quantity, uint256 _tokenId) internal virtual {
        _amount = AMOUNT;
        _price = PRICE;
        _quantity = QUANTITY;
        _tokenId = TOKEN_ID;
    }

    function configInfo(uint128 _lockTime, uint128 _referrerShare, string storage _defaultMetadata) internal virtual {
        _lockTime = LOCK_TIME;
        _referrerShare = REFERRER_SHARE;
        _defaultMetadata = DEFAULT_METADATA;
    }

    function projectInfo(
        bool _onchain,
        bool _mintEnabled,
        uint120 _maxSupply,
        string storage _contractURI
    ) internal virtual {
        _onchain = ONCHAIN;
        _mintEnabled = MINT_ENABLED;
        _maxSupply = MAX_SUPPLY;
        _contractURI = CONTRACT_URI;
    }

    function metdataInfo(
        string storage _baseURI,
        string storage _imageURI,
        bytes storage _onchainData
    ) internal virtual {
        _baseURI = BASE_URI;
        _imageURI = IMAGE_URI;
        _onchainData = ONCHAIN_DATA;
    }

    function allowlist(bytes32 _merkleRoot, address _mintPassSigner) internal virtual {
        _merkleRoot = MERKLE_ROOT;
        _mintPassSigner = MINT_PASS_SIGNER;
    }

    function initInfo(
        string memory _name,
        string memory _symbol,
        address _primaryReceiver,
        address _randomizer,
        address _renderer,
        uint256[] memory _tagIds
    ) internal virtual {
        initInfo.name = _name;
        initInfo.symbol = _symbol;
        initInfo.primaryReceiver = _primaryReceiver;
        initInfo.randomizer = _randomizer;
        initInfo.renderer = _renderer;
        initInfo.tagIds = _tagIds;
    }

    function minter(
        MintInfo _mintInfo,
        address _minter,
        uint64 _startTime,
        uint64 _endTime,
        uint64 _allocation,
        bytes memory _params
    ) internal virtual {
        _mintInfo.push(
            MintInfo({
                minter: _minter,
                reserveInfo: ReserveInfo({startTime: _startTime, endTime: _endTime, allocation: _allocation}),
                params: _params
            })
        );
    }
}
