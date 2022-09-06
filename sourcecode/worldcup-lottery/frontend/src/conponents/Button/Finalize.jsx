import { ethers } from 'ethers'
import * as React from 'react'
import { usePrepareContractWrite, useContractWrite,useWaitForTransaction, chainId, chain, useAccount } from 'wagmi'
import worldcup_abi from "../../abi/worldcup_abi.json"
import { Input } from 'antd';

export function Finalize() {
  const { config } = usePrepareContractWrite({
    addressOrName: '0x4db34635116406B5F4268FCB7463BEC97b3dcD38',
    contractInterface: worldcup_abi,
    functionName: 'finialize',
    args:[0]
  })

  const { write, data } = useContractWrite(config)
  const { isLoading, isSuccess } = useWaitForTransaction({
    hash: data?.hash,
  })

  return (
    <div>
      <button disabled={!write || isLoading} onClick={() => write()}>
        {isLoading ? 'Finalize...' : 'Finalize'}
      </button>
      <Input placeholder="country code: 0 ~ 4" />
      {isSuccess && (
        <div>
          Successfully Played !
          <div>
            <a href={`https://goerli.etherscan.io/tx/${data?.hash}`}>Etherscan</a>
          </div>
        </div>
      )}
    </div>
  )
}