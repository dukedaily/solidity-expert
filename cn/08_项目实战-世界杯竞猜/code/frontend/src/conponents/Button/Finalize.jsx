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
import worldcup_abi from '../../abi/worldcup_abi_v2.json'
import { Input, Button } from 'antd'

export function Finalize() {
  const [value, setValue] = React.useState('')
  const { config } = usePrepareContractWrite({
    addressOrName: '0x3ee1fa4d194c32428464b6725317fa0d3af380e8',
    contractInterface: worldcup_abi,
    functionName: 'finialize',
    args: [value],
  })

  const { write, data } = useContractWrite(config)
  const { isLoading, isSuccess } = useWaitForTransaction({
    hash: data?.hash,
  })

  const changeValue = (e) => {
    setValue(e.target.value)
  }
  return (
    <div>
      <Button
        type="primary"
        shape="round"
        disabled={!write || isLoading}
        onClick={() => write()}
      >
        {isLoading ? 'Finalize...' : 'Finalize'}
      </Button>
      <div>
        <Input onChange={changeValue} placeholder="country code: 0 ~ 4" />
      </div>
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
