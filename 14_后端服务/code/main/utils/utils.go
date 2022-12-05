package utils

import (
	"context"
	"crypto/ecdsa"
	"log"
	"math/big"
	"os"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/joho/godotenv"
)

var (
	GoerliHTTP = "https://goerli.infura.io/v3/1b2efe2cde144c129a46172663b24a63"
	GoerliWSS  = "wss://goerli.infura.io/ws/v3/1b2efe2cde144c129a46172663b24a63"

	// address: 0xc783df8a850f42e7f7e57013759c285caa701eb6
	PRIVATEKEY = ""
)

func init() {
	// load .env file
	err := godotenv.Load(".env")

	if err != nil {
		log.Fatalf("Error loading .env file")
	}

	PRIVATEKEY = os.Getenv("PRIVATEKEY")
	// fmt.Println("PRIVATEKEY:", PRIVATEKEY)
}

func Prepare(privKey string, value int64, client *ethclient.Client) *bind.TransactOpts {
	PRIVATEKEY, err := crypto.HexToECDSA(privKey)
	if err != nil {
		log.Fatal(err)
	}

	publicKey := PRIVATEKEY.Public()
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
	// auth, _ := bind.NewKeyedTransactorWithChainID(PRIVATEKEY, big.NewInt(int64(56)))
	auth := bind.NewKeyedTransactor(PRIVATEKEY)
	auth.Nonce = big.NewInt(int64(nonce))
	auth.Value = big.NewInt(value)
	// auth.GasLimit = uint64(300000)
	auth.GasPrice = gasPrice

	return auth
}
