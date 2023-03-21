package main

import (
	"context"
	"crypto/ecdsa"
	"encoding/hex"
	"fmt"
	"log"
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum/rlp"

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

	value := big.NewInt(10000000000000) // in wei (0.0001 eth)
	gasLimit := uint64(21000)           // in units
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

	// 以下内容不同!!
	// 解析交易，获取rawTxData
	ts := types.Transactions{signedTx}
	rawTxBytes, _ := rlp.EncodeToBytes(ts[0])
	rawTxHex := hex.EncodeToString(rawTxBytes)
	fmt.Printf("rawTxHex Encode:\n", rawTxHex) // f86...772

	// 广播交易 rawTxData
	rawTxBytesDecode, err := hex.DecodeString(rawTxHex)
	fmt.Printf("rawTxHex Decode:\n", rawTxBytesDecode)

	txNew := new(types.Transaction)
	rlp.DecodeBytes(rawTxBytesDecode, &txNew)

	err = client.SendTransaction(context.Background(), txNew)
	if err != nil {
		log.Fatal(err)
	}

	// https://testnet.bscscan.com/tx/0xe5e6f9397365298f131a2e51aa5b85bb7a7deb8b2864417f926a9cc271156220
	fmt.Printf("txNew sent: %s", txNew.Hash().Hex())
}
