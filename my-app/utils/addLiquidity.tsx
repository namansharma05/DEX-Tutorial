import { Contract, utils } from 'ethers';
import { EXCHANGE_CONTRACT_ABI, EXCHANGE_CONTRACT_ADDRESS, TOKEN_CONTRACT_ABI, TOKEN_CONTRACT_ADDRESS } from '@/constants';

export const addLiquidity = async(signer, addCDAmountWei,addEtherAmountWei) => {
    try {
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

        let txn = await tokenContract.approve(EXCHANGE_CONTRACT_ADDRESS,addCDAmountWei.toString());
        await txn.wait();
        txn = await exchangeContract.addLiquidity(addCDAmountWei,{ value: addEtherAmountWei});
        await txn.wait();
    } catch(err){
        console.error(err);
    }
}

export const calculateCD = async(_addEther = "0",etherBalanceContract,cdTokenReserve) => {
    const _addEtherAmountWei = utils.parseEther(_addEther);
    const cryptoDevTokenAmount = _addEtherAmountWei.mul(cdTokenReserve).div(etherBalanceContract);
    return cryptoDevTokenAmount;
}