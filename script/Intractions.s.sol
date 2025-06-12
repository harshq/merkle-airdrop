// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.29;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract ClaimAirdrop is Script {
    address private constant ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    bytes32 private constant PROOF1 = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 private constant PROOF2 = 0xc9aaf85fe873a2a0c9eae548123495c15ba7c697ee57074e891b8357da30fea8;
    uint256 private constant CLAIMING_AMOUNT = 25 ether;
    bytes private constant SIGNATURE =
        hex"fcc28ac94df6d25819037e98591136c7776e7f47141072390a3babc2f76edf1431225404dca4ec9b3fda5db9db47386e5516520b0377f533c65f539331529ea71b";

    function run() public {
        address airdropContractAddress = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(airdropContractAddress);
    }

    function claimAirdrop(address airdropContract) public {
        bytes32[] memory proofs = new bytes32[](2);
        proofs[0] = PROOF1;
        proofs[1] = PROOF2;

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);

        vm.startBroadcast();
        MerkleAirdrop(airdropContract).claim(ACCOUNT, CLAIMING_AMOUNT, proofs, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65, "Invalid signature length");
        assembly ("memory-safe") {
            r := mload(add(sig, 0x20))
            s := mload(add(sig, 0x40))
            v := byte(0, mload(add(sig, 0x60)))
        }
    }
}
