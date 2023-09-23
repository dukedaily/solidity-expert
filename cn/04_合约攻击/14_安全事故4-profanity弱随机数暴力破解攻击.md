# 第14节：安全事故4-profanity弱随机数暴力破解攻击

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。

最著名的就是Profanity私钥被暴力破解事件，其原因是随机数范围太小了，使用2^32位来生成2^256的随机数，导致被暴力破解，[点击查看案例分析](https://mp.weixin.qq.com/s/hVvxlVwoSfI8kaxbxIdBlA)

