# 第3节：SendTx转账

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

1. 构造交易，转账0.01ETH
2. 私钥签名
3. 广播签名交易

```go
package main

import (
	"context"
	"crypto/ecdsa"
	"fmt"
	"log"
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"

	utils "code/main/utils"
)

func main() {
	client, err := ethclient.Dial(utils.BscTestnetRpc)
	if err != nil {
		log.Fatal(err)
	}

	privateKey, err := crypto.HexToECDSA(utils.HardhatPrivateKey)
	if err != nil {
		log.Fatal(err)
	}

	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatal("cannot assert type: publicKey is not of type *ecdsa.PublicKey")
	}

	fromAddress := crypto.PubkeyToAddress(*publicKeyECDSA)
	nonce, err := client.PendingNonceAt(context.Background(), fromAddress)
	if err != nil {
		log.Fatal(err)
	}

	value := big.NewInt(10000000000000000) // in wei (0.01 eth)
	gasLimit := uint64(21000)              // in units
	gasPrice, err := client.SuggestGasPrice(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	toAddress := common.HexToAddress("0xE8191108261f3234f1C2acA52a0D5C11795Aef9E")
	var data []byte
	tx := types.NewTransaction(nonce, toAddress, value, gasLimit, gasPrice, data)

	chainID, err := client.NetworkID(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	// 私钥签名
	signedTx, err := types.SignTx(tx, types.NewEIP155Signer(chainID), privateKey)
	if err != nil {
		log.Fatal(err)
	}

	// 广播
	err = client.SendTransaction(context.Background(), signedTx)
	if err != nil {
		log.Fatal(err)
	}

	// https://testnet.bscscan.com/tx/0x07ed05b331dd9668fc4f80fee155d08a8d819194750b34469014adc368667070
	fmt.Printf("tx sent: %s", signedTx.Hash().Hex())
}
```

执行结果，[点击查看](https://testnet.bscscan.com/tx/0x07ed05b331dd9668fc4f80fee155d08a8d819194750b34469014adc368667070)

![image-20221130151255527](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221130151255527.png)