package main

import (
	"fmt"
	"log"

	utils "code/main/utils"
	store "code/src"

	"github.com/ethereum/go-ethereum/ethclient"
)

func main() {
	client, err := ethclient.Dial(utils.BscTestnetRpc)
	if err != nil {
		log.Fatal(err)
	}

	auth := utils.Prepare(utils.HardhatPrivateKey, 0, client)

	input := "1.0"
	address, tx, instance, err := store.DeployStore(auth, client, input)
	if err != nil {
		log.Fatal(err)
	}

	// 0x587bf1bc96163e279d2ea1b27f3b41cc34b171c3
	fmt.Println("address:", address.Hex())

	// https://testnet.bscscan.com/tx/0x082186993e2786744366e2147827841dc02115439d9d3786ce39a1774209d38a
	fmt.Println("tx hash:", tx.Hash().Hex())
	_ = instance
}
