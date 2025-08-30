// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IMockERC20} from "./IMockERC20.sol";

contract MockERC20 is ERC20, IMockERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    // 특정 주소에 토큰 발행
    function freeMintTo(uint256 amount, address to) external {
        // _update(address(0), to, amount);
        _mint(to, amount);
    }

    // msg.sender 에게 토큰 발행
    function freeMintToSender(uint256 amount) external {
        // _update(address(0), msg.sender, amount);
        _mint(msg.sender, amount);
    }
}
