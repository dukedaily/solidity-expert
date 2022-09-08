import { ethers } from 'ethers'
import * as React from 'react'
import {
  usePrepareContractWrite,
  useContractWrite,
  useWaitForTransaction,
  chainId,
  chain,
  useAccount,
} from 'wagmi'
import worldcup_abi from '../../abi/worldcup_abi.json'

import { Button } from 'antd'

export function ClaimReward() {
  const { config } = usePrepareContractWrite({
    addressOrName: '0x9E896316F0610Cb053C62377601F64c909668334',
    contractInterface: worldcup_abi,
    functionName: 'claimReward',
  })

  const { write, data } = useContractWrite(config)
  const { isLoading, isSuccess } = useWaitForTransaction({
    hash: data?.hash,
  })

  return (
    <div>
      <Button
        type="primary"
        shape="round"
        disabled={!write || isLoading}
        onClick={() => write()}
      >
        {isLoading ? 'claimReward...' : 'claimReward'}
      </Button>
      {isSuccess && (
        <div style={{ color: '#fff' }}>
          Successfully Played !
          <div>
            <a href={`https://goerli.etherscan.io/tx/${data?.hash}`}>
              Etherscan
            </a>
          </div>
        </div>
      )}
    </div>
  )
}
