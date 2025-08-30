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
        // Check if TokenX is not equal to TokenY
        require(_tokenX != _tokenY, "Tokens must be different");

        // Check if any of the tokens is a zero address
        require(_tokenX != address(0), "tokenX cannot be zero address");
        require(_tokenY != address(0), "tokenY cannot be zero address");

        // To fix the order of tokens in the liquidity pool regardless of the parameter order
        if (_tokenX < _tokenY) {
            tokenX = _tokenX;
            tokenY = _tokenY;
        } else {
            tokenX = _tokenY;
            tokenY = _tokenX;
        }
    }

    // this function will determine the initial 'k'.
    function _addLiquidityFirstTime(uint256 _xAmountIn, uint256 _yAmountIn) internal {
        k = _xAmountIn * _yAmountIn;
        xReserve = _xAmountIn;
        yReserve = _yAmountIn;
    }

    // this function will increase the 'k'
    // because it is transferring liquidity from users to this contract.
    function _addLiquidityNotFirstTime(uint256 _xAmountIn, uint256 _yAmountIn) internal {
        xReserve += _xAmountIn;
        yReserve += _yAmountIn;
        k = xReserve * yReserve;
    }

    function addLiquidity(uint256 _xAmountIn, uint256 _yAmountIn) external {
        // Check input amounts must be greater than 0
        require(_xAmountIn > 0 && _yAmountIn > 0, "Amounts must be greater than 0");

        // Transfer token (From User -> To Contract)
        IERC20(tokenX).transferFrom(msg.sender, address(this), _xAmountIn);
        IERC20(tokenY).transferFrom(msg.sender, address(this), _yAmountIn);
        
        // Update pool information
        if (k == 0) {
            _addLiquidityFirstTime(_xAmountIn, _yAmountIn);
        } else {
            _addLiquidityNotFirstTime(_xAmountIn, _yAmountIn);
        }
        
        // Emit event
        emit AddLiquidity(_xAmountIn, _yAmountIn);
    }

    // complete the function
function swap(uint256 _xAmountIn, uint256 _yAmountIn) external {
    // Check that at least one token is being swapped
    require(_xAmountIn > 0 || _yAmountIn > 0, "Must swap at least one token");
    // Check that only one direction can be swapped (both cannot be 0 or both non-zero)
    require((_xAmountIn > 0 && _yAmountIn == 0) || (_xAmountIn == 0 && _yAmountIn > 0), "Can only swap one direction at a time");
    // Check that there is liquidity in the pool
    require(k > 0, "No liquidity in pool");
    
    if (_xAmountIn > 0) {
        // X -> Y swap
        // Check liquidity is enough
        require(xReserve >= _xAmountIn, "Insufficient liquidity");

        uint256 expectedYOut = yReserve - (k / (xReserve + _xAmountIn));
        
        IERC20(tokenX).transferFrom(msg.sender, address(this), _xAmountIn);
        IERC20(tokenY).transfer(msg.sender, expectedYOut);
        
        // Update pool information
        xReserve += _xAmountIn;
        yReserve -= expectedYOut;
        
        // Emit event
        emit Swap(_xAmountIn, expectedYOut);
    } else {
        // Y -> X swap
        // Check liquidity is enough
        require(yReserve >= _yAmountIn, "Insufficient liquidity");

        uint256 expectedXOut = xReserve - (k / (yReserve + _yAmountIn));
        
        IERC20(tokenY).transferFrom(msg.sender, address(this), _yAmountIn);
        IERC20(tokenX).transfer(msg.sender, expectedXOut);
        
        // Update pool information
        yReserve += _yAmountIn;
        xReserve -= expectedXOut;
        
        // Emit event
        emit Swap(expectedXOut, _yAmountIn);
    }
}
}
