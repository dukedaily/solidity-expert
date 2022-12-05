package main

import (
	"fmt"
	"log"

	utils "code/main/utils"
	store "code/src"

	"github.com/ethereum/go-ethereum/ethclient"
)

func main() {
	client, err := ethclient.Dial(utils.GoerliHTTP)
	if err != nil {
		log.Fatal(err)
	}

	auth := utils.Prepare(utils.PRIVATEKEY, 0, client)

	input := "1.0"
	address, tx, instance, err := store.DeployStore(auth, client, input)
	if err != nil {
		log.Fatal(err)
	}

	// 0xE4a220e0bd37673A90E2114Abc98e4a22445c32e
	fmt.Println("address:", address.Hex())

	// https://goerli.etherscan.io/address/0xe4a220e0bd37673a90e2114abc98e4a22445c32e
	fmt.Println("tx hash:", tx.Hash().Hex())
	_ = instance
}
