package main

import (
	utils "code/main/utils"
	"context"
	"fmt"
	"log"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
)

func main() {
	client, err := ethclient.Dial(utils.GoerliWSS)
	if err != nil {
		log.Fatal("Dial err:", err)
	}

	// 1. 准备合约地址
	contractAddr := "0xe4a220e0bd37673a90e2114abc98e4a22445c32e"
	address := common.HexToAddress(contractAddr)

	// 2. 构造过滤查询条件
	query := ethereum.FilterQuery{
		Addresses: []common.Address{address},
		// FromBlock: new(big.Int).SetUint64(0),
		// ToBlock:   new(big.Int).SetUint64(1),
	}

	// 3. 订阅事件
	logs := make(chan types.Log)
	sub, err := client.SubscribeFilterLogs(context.Background(), query, logs)
	if err != nil {
		log.Fatal(err)
	}

	for {
		fmt.Println("ready to listen...")
		select {
		case err := <-sub.Err():
			log.Fatal(err)
		case vLog := <-logs:
			fmt.Println(vLog)
		}
	}
}
