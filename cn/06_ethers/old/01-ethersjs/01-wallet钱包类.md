# wallet

1. 钱包wallet类管理者一个公私钥对，用于在以太坊网络上密码签名交易以及所有权证明。
2. wallet是签名器的实现，任何需要签名器的地方使用wallet即可。wallet实现了signer的所有API
3. wallet可以创建私钥、加载私钥、也可以进行签名，发送交易：这些来自SignerAPI
