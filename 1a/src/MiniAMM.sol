// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {IMiniAMM, IMiniAMMEvents} from "./IMiniAMM.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Add as many variables or functions as you would like
// for the implementation. The goal is to pass `forge test`.
contract MiniAMM is IMiniAMM, IMiniAMMEvents {
    uint256 public k = 0;
    uint256 public xReserve = 0;
    uint256 public yReserve = 0;

    address public tokenX;
    address public tokenY;

    // implement constructor
    constructor(address _tokenX, address _tokenY) {
        // To fix the order of tokens in the liquidity pool regardless of the parameter order
        if (_tokenX > _tokenY) {
            tokenX = _tokenX;
            tokenY = _tokenY;
        } else {
            tokenX = _tokenY;
            tokenY = _tokenX;
        }
    }

    // add parameters and implement function.
    // this function will determine the initial 'k'.
    function _addLiquidityFirstTime(uint256 xAmountIn, uint256 yAmountIn) internal {
        k = xAmountIn * yAmountIn;
        xReserve = xAmountIn;
        yReserve = yAmountIn;
    }

    // this function will increase the 'k'
    // because it is transferring liquidity from users to this contract.
    function _addLiquidityNotFirstTime(uint256 xAmountIn, uint256 yAmountIn) internal {
        xReserve += xAmountIn;
        yReserve += yAmountIn;
        k = xReserve * yReserve;
    }

    // complete the function
    function addLiquidity(uint256 xAmountIn, uint256 yAmountIn) external {
        // Transfer token (From User -> To Contract)
        IERC20(tokenX).transferFrom(msg.sender, address(this), xAmountIn);
        IERC20(tokenY).transferFrom(msg.sender, address(this), yAmountIn);
        
        // Update pool information
        if (k == 0) {
            _addLiquidityFirstTime(xAmountIn, yAmountIn);
        } else {
            _addLiquidityNotFirstTime(xAmountIn, yAmountIn);
        }
        
        // Emit event
        emit AddLiquidity(xAmountIn, yAmountIn);
    }

    // complete the function
    function swap(uint256 xAmountIn, uint256 yAmountIn) external {}
}
