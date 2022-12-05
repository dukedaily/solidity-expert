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
	client, err := ethclient.Dial(utils.GoerliHTTP)
	if err != nil {
		log.Fatal(err)
	}

	privateKey, err := crypto.HexToECDSA(utils.PRIVATEKEY)
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

	value := big.NewInt(100000000000000) // in wei (0.001 eth)
	gasLimit := uint64(21000)            // in units
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

	fmt.Println("signedTx:", signedTx)

	// 广播
	err = client.SendTransaction(context.Background(), signedTx)
	if err != nil {
		log.Fatal(err)
	}

	// https://testnet.bscscan.com/tx/0x07ed05b331dd9668fc4f80fee155d08a8d819194750b34469014adc368667070
	fmt.Printf("tx sent: %s", signedTx.Hash().Hex())

	// recipient, err := client.TransactionReceipt(context.Background(), signedTx.Hash())
	// if err != nil {
	// 	log.Fatal("recipient err:", err)
	// }

	// fmt.Println("recipient:", recipient)
}
