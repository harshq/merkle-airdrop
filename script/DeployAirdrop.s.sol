// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.29;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {BunToken} from "src/BunToken.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract DeployContractAirdrop is Script {
    bytes32 private constant ROOT = 0x75ffe99bc33faf8f49b5fe2cf58757d53774497c822ad45a49ec21fa121b9019;
    uint256 private constant AIRDROP_AMOUNT = 25 ether;
    uint256 private constant AIRDROP_COUNT = 4;

    function run() public returns (BunToken token, MerkleAirdrop airdrop) {
        return deployContracts();
    }

    function deployContracts() public returns (BunToken, MerkleAirdrop) {
        vm.startBroadcast();
        BunToken token = new BunToken();

        token.mint(token.owner(), AIRDROP_AMOUNT * AIRDROP_COUNT);
        MerkleAirdrop airdrop = new MerkleAirdrop(ROOT, IERC20(token));

        token.transfer(address(airdrop), AIRDROP_AMOUNT * AIRDROP_COUNT);
        vm.stopBroadcast();
        return (token, airdrop);
    }
}
