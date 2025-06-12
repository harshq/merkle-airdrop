// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.29;

import {Test, console} from "forge-std/Test.sol";
import {BunToken} from "src/BunToken.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {DeployContractAirdrop} from "script/DeployAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    BunToken token;
    MerkleAirdrop airdrop;
    bytes32 constant ROOT = 0x75ffe99bc33faf8f49b5fe2cf58757d53774497c822ad45a49ec21fa121b9019;
    uint256 constant CLAIM_AMOUNT = 25 ether;
    address user;
    address gasPayer;
    uint256 userPrivKey;

    function setUp() public {
        DeployContractAirdrop deployer = new DeployContractAirdrop();
        (token, airdrop) = deployer.run();
        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        bytes32[] memory proofs = new bytes32[](2);
        proofs[0] = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
        proofs[1] = 0xc9aaf85fe873a2a0c9eae548123495c15ba7c697ee57074e891b8357da30fea8;

        uint256 startingBalance = token.balanceOf(user);
        bytes32 message = airdrop.getMessageHash(user, CLAIM_AMOUNT);

        // user signs the message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, message);

        // gas payer claims
        vm.prank(gasPayer);
        airdrop.claim(user, CLAIM_AMOUNT, proofs, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        assertEq(endingBalance, startingBalance + 25 ether);
    }
}
