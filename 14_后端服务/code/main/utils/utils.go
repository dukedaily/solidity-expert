package utils

import (
	"context"
	"crypto/ecdsa"
	"log"
	"math/big"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
)

var (
	BscTestnetRpc = "https://data-seed-prebsc-2-s1.binance.org:8545"

	// address: 0xc783df8a850f42e7f7e57013759c285caa701eb6
	HardhatPrivateKey = "c5e8f61d1ab959b397eecc0a37a6517b8e67a0e7cf1f4bce5591f3ed80199122"
)

func Prepare(privKey string, value int64, client *ethclient.Client) *bind.TransactOpts {
	privateKey, err := crypto.HexToECDSA(privKey)
	if err != nil {
		log.Fatal(err)
	}

	publicKey := privateKey.Public()
	publicKeECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatal("invalid public key type")
	}

	fromAddress := crypto.PubkeyToAddress(*publicKeECDSA)
	nonce, err := client.PendingNonceAt(context.Background(), fromAddress)
	if err != nil {
		log.Fatal(err)
	}

	gasPrice, err := client.SuggestGasPrice(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	// chainId := 56
	// auth, _ := bind.NewKeyedTransactorWithChainID(privateKey, big.NewInt(int64(56)))
	auth := bind.NewKeyedTransactor(privateKey)
	auth.Nonce = big.NewInt(int64(nonce))
	auth.Value = big.NewInt(value)
	// auth.GasLimit = uint64(300000)
	auth.GasPrice = gasPrice

	return auth
}
