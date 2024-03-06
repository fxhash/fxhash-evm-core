// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {EIP712} from "solady/src/utils/EIP712.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";
import {SignatureCheckerLib} from "solady/src/utils/SignatureCheckerLib.sol";

import {IFxGenArt721, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFarcasterFrame} from "src/interfaces/IFarcasterFrame.sol";

/**
 * @title FarcasterFrame
 * @author fx(hash)
 * @dev See the documentation in {IFarcasterFrame}
 */
contract FarcasterFrame is IFarcasterFrame, EIP712, Ownable, Pausable {
    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    bytes32 public constant MINT_TYPEHASH = keccak256("mint(address token,address to,uint256 amount,uint256 fid)");
    address public signer;
    mapping(address => uint256) public maxAmounts;
    mapping(address => ReserveInfo) public reserves;
    mapping(uint256 => bool) public hasMinted;

    constructor(address _signer) {
        signer = _signer;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function mint(
        address _token,
        address _to,
        uint256 _amount,
        uint256 _fid,
        bytes calldata _signature
    ) external whenNotPaused {
        // if (!_verifySignature(_token, _to, _amount, _fid, _signature)) revert InvalidSignature();
        // if (hasMinted[fid]) revert AlreadyMinted();
        if (_to == address(0)) revert ZeroAddress();
        if (_amount > maxAmounts[_token]) revert InvalidAmount();
        ReserveInfo memory reserveInfo = reserves[_token];
        if (reserveInfo.startTime > block.timestamp || reserveInfo.endTime < block.timestamp) {
            revert InvalidTime();
        }

        hasMinted[_fid] = true;
        reserves[_token].allocation--;

        IFxGenArt721(_token).mint(_to, _amount, 0);

        emit FrameMinted(_token, _to, _fid);
    }

    function setMintDetails(ReserveInfo calldata _reserveInfo, bytes calldata _mintDetails) external whenNotPaused {
        uint256 maxAmount = abi.decode(_mintDetails, (uint256));
        maxAmounts[msg.sender] = maxAmount;
        reserves[msg.sender] = _reserveInfo;

        emit MintDetailsSet(msg.sender, _reserveInfo, maxAmount);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function pause() external onlyOwner {
        _pause();
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function hashTypedData(bytes32 structHash) public view returns (bytes32) {
        return _hashTypedData(structHash);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _verifySignature(
        address _token,
        address _to,
        uint256 _amount,
        uint256 _fid,
        bytes calldata _signature
    ) internal view returns (bool) {
        bytes32 digest = _hashTypedData(keccak256(abi.encode(MINT_TYPEHASH, _token, _to, _amount, _fid)));
        return SignatureCheckerLib.isValidSignatureNowCalldata(signer, digest, _signature);
    }

    function _domainNameAndVersion() internal pure override returns (string memory, string memory) {
        return ("Farcaster Frame Minter", "1");
    }
}
