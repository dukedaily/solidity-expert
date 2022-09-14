# 第9节：Gas相关

![image-20220914075834102](assets/image-20220914075834102.png)

**gas描述执行一笔交易时需要花费多少ether！（1 ether = 10^18wei)**

交易手续费 = **gas_used * gas_price**，其中：

1. gas：是数量单位，uint
2. gas_used：表示一笔交易实际消耗的gas数量
3. gas_price：每个gas的价格，单位是wei或gwei
4. gas limit：表示你允许这一笔交易消耗的gas上限，用户自己设置（防止因为bug导致的损失）
   1. 如果gas_used小于gas_limit，剩余gas会返回给用户，这个值不再合约层面设置，在交易层面设置（如metamask）
   2. 如果gas_used大于gas_limit，交易失败，资金不退回
5. block gas limit：表示一个区块能够允许的最大gas数量，由区块链网络设置

![image-20220506182558786](assets/image-20220506182558786.png)

验证：

```sh
gas_used:  197083
gas_price: 0.000000078489891145
cost = gas_used * gas_price = 197083 * 0.000000078489891145 = 0.015469023216530034，#与上图一致
```

