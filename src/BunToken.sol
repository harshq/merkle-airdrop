// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.29;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BunToken is ERC20, Ownable {
    constructor() ERC20("BunToken", "BUN") Ownable(msg.sender) {}

    function mint(address _to, uint256 _amountToMint) public onlyOwner {
        _mint(_to, _amountToMint);
    }
}
