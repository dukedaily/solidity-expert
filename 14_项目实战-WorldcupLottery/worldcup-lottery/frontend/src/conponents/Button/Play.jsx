import { ethers } from 'ethers'
// import * as React from 'react'
import {
  usePrepareContractWrite,
  useContractWrite,
  useWaitForTransaction,
  chainId,
  chain,
  useAccount,
} from 'wagmi'
import worldcup_abi from '../../abi/worldcup_abi.json'
import { Input, Button } from 'antd'
import { React, useState } from 'react'

// const App = () => <Input placeholder="Basic usage" />;

// export default App;

export function Play() {
  // const [input, setInput] = useState(null)
  const { config } = usePrepareContractWrite({
    addressOrName: '0x4db34635116406B5F4268FCB7463BEC97b3dcD38',
    contractInterface: worldcup_abi,
    functionName: 'play',
    args: [0],
    overrides: {
      value: '1000000000', //这里要传递字符串
    },
  })

  const { write, data } = useContractWrite(config)
  const { isLoading, isSuccess } = useWaitForTransaction({
    hash: data?.hash,
  })

  const onInput = () => {}

  return (
    <div>
      <Button
        type="primary"
        shape="round"
        disabled={!write || isLoading}
        onClick={() => write()}
      >
        {isLoading ? 'Playing...' : 'Play'}
      </Button>
      <div>
        <Input placeholder="country code: 0 ~ 4" />
      </div>
      {isSuccess && (
        <div style={{ color: '#fff' }}>
          Successfully Played !
          <div>
            <a
              target="_blank"
              href={`https://goerli.etherscan.io/tx/${data?.hash}`}
              rel="noreferrer"
            >
              Etherscan
            </a>
          </div>
        </div>
      )}
    </div>
  )
}
