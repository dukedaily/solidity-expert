clean:
	rm -rf metadata

compile:
	 solc --abi --bin contracts/Store.sol -o metadata

build:
	abigen --abi=metadata/Store.abi --bin=metadata/Store.bin --pkg=store --out=src/Store.go

deploy:
	go run main/01_deploy.go

write:
	go run main/02_readWrite.go

send:
	go run main/03_sendETH.go

sendRaw:
	go run main/04_sendRawTx.go

subscribe:
	go run main/05_subscribeEvent.go

parse:
	go run main/06_parseEvent.go