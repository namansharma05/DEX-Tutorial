//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20{

    address public CryptoDevTokenAddress;

    constructor(address _CrypotDevToken) ERC20("CryptoDev LP Token","CDLP"){
        require(_CrypotDevToken!=address(0),"Token address passed is a null address");
        CryptoDevTokenAddress = _CrypotDevToken;
    }

    function getReserve() public view returns(uint){
        return ERC20(CryptoDevTokenAddress).balanceOf(address(this));
    }

    function addLiquidity(uint _amount) public payable returns(uint){
        uint liquidity;
        uint ethBalance = address(this).balance;
        uint cryptoDevTokenReserve = getReserve();
        ERC20 cryptoDevToken = ERC20(CryptoDevTokenAddress);
        if(cryptoDevTokenReserve == 0){
            cryptoDevToken.transferFrom(msg.sender,address(this),_amount);
            liquidity = ethBalance;
            _mint(msg.sender,liquidity);
        } else {
            uint ethReserve = ethBalance-msg.value;
            uint cryptoDevTokenAmount = (msg.value * cryptoDevTokenReserve)/(ethReserve);
            require(_amount >= cryptoDevTokenAmount,"Amount of Tokens is less than the minimum tokens required");
            cryptoDevToken.transferFrom(msg.sender,address(this),cryptoDevTokenAmount);
            liquidity = (totalSupply() * msg.value)/ethReserve;
            _mint(msg.sender,liquidity);
        }
        return liquidity;
    }

    function removeLiquidity(uint _amount) public returns(uint,uint){
        require(_amount>0,"_amount should be greater than zero");
        uint ethReserve = address(this).balance;
        uint _totalSupply = totalSupply();
        uint ethAmount = (ethReserve * _amount)/_totalSupply;
        uint cryptoDevTokenAmount = (getReserve() * _amount)/_totalSupply;
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(ethAmount);
        ERC20(CryptoDevTokenAddress).transfer(msg.sender, cryptoDevTokenAmount);
        return (ethAmount, cryptoDevTokenAmount);
    }

    function getAmountOfToken(uint inputAmount,uint inputReserve,uint outputReserve) public pure returns (uint){
        require(inputReserve > 0 && outputReserve > 0, "input reserves");
        uint inputAmountWithFee = inputAmount * 99;
        uint numerator = inputAmountWithFee * outputReserve;
        uint denominator = (inputReserve * 100) + inputAmountWithFee;
        return numerator/denominator;
    }

    function ethToCryptoDevToken(uint _minTokens) public payable{
        uint tokenReserve = getReserve();
        uint tokensBought = getAmountOfToken(msg.value,address(this).balance-msg.value,tokenReserve);
        require(tokensBought >= _minTokens,"insufficient output amount");
        ERC20(CryptoDevTokenAddress).transfer(msg.sender,tokensBought);
    }
    function cryptoDevTokenToEth(uint _tokensSold,uint _minEth) public payable{
        uint tokenReserve = getReserve();
        uint ethBought = getAmountOfToken(_tokensSold,tokenReserve,address(this).balance);
        require(ethBought >= _minEth,"insufficient output amount");
        ERC20(CryptoDevTokenAddress).transferFrom(msg.sender,address(this),_tokensSold);
        payable(msg.sender).transfer(ethBought);
    }
}