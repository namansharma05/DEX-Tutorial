import { Contract } from 'ethers';
import { EXCHANGE_CONTRACT_ABI, EXCHANGE_CONTRACT_ADDRESS, TOKEN_CONTRACT_ABI, TOKEN_CONTRACT_ADDRESS } from '@/constants';

export const getAmountOfTokensReceivedFromSwap = async(_swapAmountWei,provider,ethSelected,ethBalance,reserveCD) => {
    const exchangeContract = new Contract(
        EXCHANGE_CONTRACT_ADDRESS,
        EXCHANGE_CONTRACT_ABI,
        provider,
    );

    let amountOfTokens;

    if(ethSelected) {
        amountOfTokens = await exchangeContract.getAmountOfTokens(_swapAmountWei,ethBalance,reserveCD);
    } else {
        amountOfTokens = await exchangeContract.getAmountOfTokens(_swapAmountWei,reserveCD,ethBalance);
    }
    return amountOfTokens;
}

export const swapTokens = async(signer,swapAmountWei,tokenToBeReceivedAfterSwap,ethSelected) => {
    const tokenContract = new Contract(
        TOKEN_CONTRACT_ADDRESS,
        TOKEN_CONTRACT_ABI,
        signer,
    );

    const exchangeContract = new Contract(
        EXCHANGE_CONTRACT_ADDRESS,
        EXCHANGE_CONTRACT_ABI,
        signer,
    );

    let txn;
    if(ethSelected){
        txn = await tokenContract.ethToCryptoDevToken(tokenToBeReceivedAfterSwap,{value:swapAmountWei});
    } else {
        txn = await tokenContract.approve(
            EXCHANGE_CONTRACT_ADDRESS,
            swapAmountWei.toString(),
        );
        await txn.wait();
        txn = await exchangeContract.cryptoDevTokenToEth(swapAmountWei,tokenToBeReceivedAfterSwap);
    }
    await txn.wait();
}