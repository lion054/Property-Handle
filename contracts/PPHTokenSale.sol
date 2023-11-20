pragma solidity >=0.4.22 <0.9.0;

// SPDX-License-Identifier: MIT

import "./PPHToken.sol";

contract PPHTokenSale {
    address public admin;
    PPHToken public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;

    event Sell(address _buyer, uint256 _amount);

    constructor(PPHToken _tokenContract, uint256 _tokenPrice) {
        admin = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }

    //multiply function
    function multiply(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    //Buying the tokens
    function buyTokens(uint256 _numberOfTokens) public payable {
        //require that value is equal to tokens
        require(msg.value == multiply(_numberOfTokens, tokenPrice));
        //require contract has enough tokens
        require(
            tokenContract.balanceOf(address(this)) >= _numberOfTokens,
            "Not enough tokens in the contract"
        );
        //require transfer is successful
        require(
            tokenContract.transfer(msg.sender, _numberOfTokens),
            "Token transfer failed"
        );
        //keep track of tokensSold
        tokensSold += _numberOfTokens;
        //trigger sell event
        emit Sell(msg.sender, _numberOfTokens);
    }
}