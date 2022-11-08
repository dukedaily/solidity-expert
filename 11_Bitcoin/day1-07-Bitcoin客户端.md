# 一、工具下载

## 1. [地址](https://bitcoincore.org/en/download/)

这里面可以下载命令行工具和图像化客户端，图形化可自行下载安装，但是先不要运行，看完本教程再运行。

我们这里重点讲命令行工具，因为这个包里面包含了图形化工具。

![image-20221108131131222](assets/image-20221108131131222.png)



## 2. 源码

如果想自己编译，可以自行下载比特币核心源码，里面的doc文件夹下面有不同平台的编译说明，请自行尝试。

仓库如下：

```sh
duke ~/btc/bitcoin_src$  git remote -v
origin	https://github.com/bitcoin/bitcoin.git (fetch)
origin	https://github.com/bitcoin/bitcoin.git (push)
```



## 3. 工具介绍

* bitcoin-qt 是图形化的工具，启动后与图形化安装版本（BitCoin Core）效果一致，这两个都不会启动bitcoind，应该是内置了服务，另，BitCoin Core后台启动的名字叫`BitCoin-Qt`，可以使用grep查看。

* bitcoind是后台服务，可以手动启动，通过控制参数，选择运行网络（主网络，测试网络，本地私有网络）
* bitcoin-cli是客户端，与bitcoind配合使用。



# 二、使用

## 1. 图形化客户端默认安装目录

```js
Windows XP - C:\Documents and Settings\{username}\Application Data\Bitcoin\wallet.dat
%appdata%
Windows 7/8 - C:\Users\{username}\AppData\Roaming\Bitcoin\wallet.dat
Mac OS X ~/Library/Application Support/Bitcoin/wallet.dat
Linux ~/.bitcoin/wallet.dat
```



## 2. 创建配置文件

* 文件名：bitcoin.conf

* 配置文件可有可无，默认是没有创建的。

* 如果没有这个文件，可以在启动程序时使用参数进行控制，如果配置文件存在，程序会同时读取命令行参数和配置文件的数据，所以要保证两个参数不要冲突，冲突会报错。



## 3. bitcoin-qt

这个程序启动时会查找默认安装路径（~/Library/Application Support/Bitcoin），如果没有这个目录，它会引导用户去指定一个新的目录，在那个指定目录下创建配置文件`bitcoin.conf`即可。



## 4. bitcoind

这个程序寻找默认目录，如果目录不存在会自动创建，简单粗暴。



## 5. 修改配置文件

这个配置文件不能用//来注释汉字。

```js
regtest=1  //这个如果不写，就是真实网路，testnet=1是测试网络testnet3，regtest=1是私有网络
rpcbind=127.0.0.1
rpcallowip=127.0.0.1
rpcuser=test
rpcpassword=test
server=1
//daemon=1  //后台
//txindex=1
```



## 6. 启动服务

可以使用bitcoind来启动，也可以使用图形化客户端启动，两者都会读取配置文件指示来运行

如果是图形化界面，可以根据图标的颜色来一眼识别出当前的网络：

![image-20221108131224848](assets/image-20221108131224848.png)



# 三、命令

## 1. 常用命令

| 命令                 | 使用 | 备注 |
| -------------------- | ---- | ---- |
| getbestblockhash     |      |      |
| getblock             |      |      |
| getblockchaininfo    |      |      |
| getrawtransaction    |      |      |
| decoderawtransaction |      |      |
| gettransaction       |      |      |
| dumpprivkey          |      |      |
| generate             |      |      |
| gettxout             |      |      |
|                      |      |      |
|                      |      |      |



## 2. 所有命令

```go
== Blockchain ==
getbestblockhash		//最后一个区块的哈希
getblock "blockhash" ( verbosity ) 
getblockchaininfo
getblockcount
getblockhash height
getblockheader "hash" ( verbose )
getchaintips
getchaintxstats ( nblocks blockhash ) //统计区块数量，交易数量
getdifficulty
getmempoolancestors txid (verbose)  //必须是在内存中的交易才有效
getmempooldescendants txid (verbose) //TODO
getmempoolentry txid	//TODO
getmempoolinfo	//当前内存中的交易数据，可读，别和getmemoryinfo混淆了
getrawmempool ( verbose )  //返回交易id
gettxout "txid" n ( include_mempool )  //引用交易id内的第n个output
gettxoutproof ["txid",...] ( blockhash ) //TODO
gettxoutsetinfo //统计utxo
preciousblock "blockhash" //TODO
pruneblockchain //TODO，必须在prune mode才能删除旧区块
savemempool //将内存交易保存到磁盘中，当前内存中有2笔交易，为何返回null TODO
verifychain ( checklevel nblocks ) //返回true
verifytxoutproof "proof" //TODO

== Control ==
getmemoryinfo ("mode") //TODO
help ( "command" )
logging ( <include> <exclude> ) //会返回一个值全0的json，不知道如何产生数据
stop //直接退出当前BitCoin Core，手残
uptime //当前客户端启动多久了

== Generating ==
generate nblocks ( maxtries ) //手动执行挖矿，每个块奖励50BTC，由默认账户挖矿
generatetoaddress nblocks address (maxtries) //指定挖矿人

== Mining ==
getblocktemplate ( TemplateRequest ) //TODO，得联网？？
getmininginfo
getnetworkhashps ( nblocks height )   //算力？？8.913976854892111e-07
prioritisetransaction <txid> <dummy value> <fee delta>
submitblock "hexdata"  ( "dummy" ) //TODO

== Network ==
addnode "node" "add|remove|onetry"
clearbanned
disconnectnode "[address]" [nodeid]
getaddednodeinfo ( "node" )
getconnectioncount
getnettotals
getnetworkinfo
getpeerinfo
listbanned
ping
setban "subnet" "add|remove" (bantime) (absolute)
setnetworkactive true|false

== Rawtransactions ==  //TODO
combinerawtransaction ["hexstring",...]
createrawtransaction [{"txid":"id","vout":n},...] {"address":amount,"data":"hex",...} ( locktime ) ( replaceable )
decoderawtransaction "hexstring" ( iswitness )
decodescript "hexstring"
fundrawtransaction "hexstring" ( options iswitness )
getrawtransaction "txid" ( verbose "blockhash" )
sendrawtransaction "hexstring" ( allowhighfees )
signrawtransaction "hexstring" ( [{"txid":"id","vout":n,"scriptPubKey":"hex","redeemScript":"hex"},...] ["privatekey1",...] sighashtype )

== Util ==
createmultisig nrequired ["key",...]
estimatefee nblocks
estimatesmartfee conf_target ("estimate_mode")
signmessagewithprivkey "privkey" "message"
validateaddress "address"
verifymessage "address" "signature" "message"

== Wallet ==
abandontransaction "txid"
abortrescan
addmultisigaddress nrequired ["key",...] ( "account" "address_type" )
backupwallet "destination"
bumpfee "txid" ( options ) 
dumpprivkey "address"
dumpwallet "filename"
encryptwallet "passphrase"
getaccount "address"  //user1
getaccountaddress "account"
getaddressesbyaccount "account"
getbalance ( "account" minconf include_watchonly )
getnewaddress ( "account" "address_type" )
getrawchangeaddress ( "address_type" )
getreceivedbyaccount "account" ( minconf )
getreceivedbyaddress "address" ( minconf )
gettransaction "txid" ( include_watchonly )
getunconfirmedbalance
getwalletinfo
importaddress "address" ( "label" rescan p2sh )
importmulti "requests" ( "options" )
importprivkey "privkey" ( "label" ) ( rescan )
importprunedfunds
importpubkey "pubkey" ( "label" rescan )
importwallet "filename"
keypoolrefill ( newsize )
listaccounts ( minconf include_watchonly)
listaddressgroupings
listlockunspent
listreceivedbyaccount ( minconf include_empty include_watchonly)
listreceivedbyaddress ( minconf include_empty include_watchonly)
listsinceblock ( "blockhash" target_confirmations include_watchonly include_removed )
listtransactions ( "account" count skip include_watchonly)
listunspent ( minconf maxconf  ["addresses",...] [include_unsafe] [query_options])
listwallets
lockunspent unlock ([{"txid":"txid","vout":n},...])
move "fromaccount" "toaccount" amount ( minconf "comment" )
removeprunedfunds "txid"
rescanblockchain ("start_height") ("stop_height")
sendfrom "fromaccount" "toaddress" amount ( minconf "comment" "comment_to" )
sendmany "fromaccount" {"address":amount,...} ( minconf "comment" ["address",...] replaceable conf_target "estimate_mode")
sendtoaddress "address" amount ( "comment" "comment_to" subtractfeefromamount replaceable conf_target "estimate_mode")
setaccount "address" "account"
settxfee amount
signmessage "address" "message"
walletlock
walletpassphrase "passphrase" timeout
walletpassphrasechange "oldpassphrase" "newpassphrase"

```



# 四. 参考链接

1. [最初参考](http://ju.outofmemory.cn/entry/345554)
2. [测试网络浏览器](https://testnet.blockexplorer.com)
3. [官方手册](https://bitcoincore.org/en/doc/0.16.2/rpc/blockchain/getbestblockhash/)