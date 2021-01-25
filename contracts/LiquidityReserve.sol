// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./external/IUniswapV2Factory.sol";
import "./external/IUniswapV2Router02.sol";
import "./Constants.sol";
import "./XST.sol";

contract LiquidityReserve is Context, Ownable {
    using SafeMath for uint256;
    using Address for address;
    XStable token;
    IUniswapV2Router02 public uniswapRouterV2;
    IUniswapV2Factory public uniswapFactory;
    modifier sendTaxless {
        token.setTaxless(true);
        _;
        token.setTaxless(false);
    }
    constructor (address tokenAdd) public {
        token = XStable(tokenAdd);
        uniswapRouterV2 = IUniswapV2Router02(Constants.getRouterAdd());
        uniswapFactory = IUniswapV2Factory(Constants.getFactoryAdd());
    }
    function convertToLiquidity() external payable sendTaxless {
        require(token.balanceOf(address(this)) >= Constants.getMinForLiquidity(), "Less than minimum tokens");
        require(token.balanceOf(_msgSender()) >= Constants.getMinForCallerLiquidity(), "Less than min caller tokens");
        require(!Address.isContract(_msgSender()),"cannot be contract");
        address tokenUniswapPair = uniswapFactory.getPair(address(token),uniswapRouterV2.WETH());
        token.transfer(_msgSender(),Constants.getLiquidityReward());
        uint256 amountToSwap = token.balanceOf(address(this)).div(2);
        address pairToken = uniswapRouterV2.WETH();
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = pairToken;
        token.approve(address(uniswapRouterV2), token.balanceOf(address(this)));
        uniswapRouterV2.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap, 0, path, address(this), block.timestamp);
        uint256 newEthBal = IERC20(pairToken).balanceOf(address(this));
        IERC20(pairToken).approve(address(uniswapRouterV2), newEthBal);
        uniswapRouterV2.addLiquidity(address(token),pairToken,amountToSwap,newEthBal,0,0,address(token),block.timestamp);
        token.silentSyncPair(tokenUniswapPair);
    }
}