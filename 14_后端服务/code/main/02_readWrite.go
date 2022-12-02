package main

import (
	utils "code/main/utils"
	store "code/src"
	"fmt"
	"log"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
)

func main() {
	client, err := ethclient.Dial(utils.GoerliHTTP)
	if err != nil {
		log.Fatal(err)
	}

	// 1. 准备合约地址
	contractAddr := "0xE4a220e0bd37673A90E2114Abc98e4a22445c32e"
	address := common.HexToAddress(contractAddr)

	// 2. 创建合约实例
	instance, err := store.NewStore(address, client)
	if err != nil {
		log.Fatal(err)
	}

	// 3. 读取合约
	version, err := instance.Version(nil)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("version:", version)

	/// 4. 构造私钥相关数据
	// address: 0xc783df8a850f42e7f7e57013759c285caa701eb6
	auth := utils.Prepare(utils.HardhatPrivateKey, 0, client)

	// 5. 写合约
	key := [32]byte{}
	value := [32]byte{}
	copy(key[:], []byte("foo"))
	copy(value[:], []byte("bar"))

	tx, err := instance.SetItem(auth, key, value)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("tx sent: %s\n", tx.Hash().Hex())

	// 6. 再次读取合约
	result, err := instance.Items(nil, key)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("result:", string(result[:]))
}
