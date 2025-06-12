// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.29;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed(address account);
    error MerkleAirdrop__InvalidSignature();

    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_token;
    mapping(address => bool) s_hasClaimed;

    constructor(bytes32 _merkleRoot, IERC20 _token) EIP712("MerkleAirdrop", "1.0") {
        i_merkleRoot = _merkleRoot;
        i_token = _token;
    }

    event ClaimTokens(address indexed account, uint256 indexed amount);

    function claim(address _account, uint256 _amount, bytes32[] calldata _merkleProof, uint8 _v, bytes32 _r, bytes32 _s)
        external
    {
        // Checks
        if (s_hasClaimed[_account]) {
            revert MerkleAirdrop__AlreadyClaimed(_account);
        }

        if (!_isValidSignature(_account, getMessageHash(_account, _amount), _v, _r, _s)) {
            revert MerkleAirdrop__InvalidSignature();
        }

        // calculate hash using account and amount.
        // that hash is a leaf node
        bytes32 hash = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount))));
        if (!MerkleProof.verify(_merkleProof, i_merkleRoot, hash)) {
            revert MerkleAirdrop__InvalidProof();
        }

        // Effects
        s_hasClaimed[_account] = true;
        emit ClaimTokens(_account, _amount);
        // Interactions
        i_token.safeTransfer(_account, _amount);
    }

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address signer,,) = ECDSA.tryRecover(digest, v, r, s);
        return signer == account;
    }

    // return from this is called message digest.
    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }
}
