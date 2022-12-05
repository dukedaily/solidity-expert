## 关于IP Rights 与Ownership的探讨



WIP



## 几个问题

1. **What are intellectual property rights and NFTs? ** 什么是知识产权和 NFT？

   ```sh
   IP rights一般分为4种，Copyrights、Trademarks、Patents、Trade Secrets，我们的NFT一般指的是copyright。
   # There are four main types of Intellectual Property, that would be : Copyrights, Trademarks, Patents, & Trade Secrets.
   
   # when we talk about IP Rights for NFT, Copyright is what we're usually referring to. 
   
   # what is nft, i'll explain this in a technical view, the code for nft is very simple, what differs an normal token(USDT) from a NFT is that the NFT has applied an unique tokenid for each token, and bound this tokenid to an special pic url( metadata actually).
   
   
   # so each token is uniquie, and you can see a pic for each token.
   
   
   
   NFT是非同质化token，大家都已经讲了概念，我这里就换一个角度来介绍，NFT是token的一种，分为721，和1155，在技术上和USDT不同之处是没有decimals概念，
   
   每个Token绑定了一个唯一的uri，也就是metadata的链接，在metadata中会进一步包含一个资源的都url，这个url可以是图片都，也可以是video的。从技术层面来
   讲，这是一个非常普通的token，代码非常简单，NFT是建立在区块链之上的，是智能合约成就了NFT，而不是NFT本身有多么复杂。
   
   NFT的底层是冰冷的token，使人为的共识让NFT有了温度，进而聚集了更多的人，组建了社区，产生了共识，进而赋予了价值。
   
   
   Intellectual Property is a catch-all term to describe property rights related to non-physical assets. There are four main types of Intellectual Property: Copyrights, Trademarks, Patents, & Trade Secrets. Given that Copyright is the primary legally recognized form of IP for digital content, we’ll focus our attention here. Note that whenever a project says you own the IP or have IP rights, Copyright is what they're usually referring to. 
   
   Since they have already talk about alll these items in NFT..., i' will explain this is a technical way.
   
   Non-Fungible Tokens, commonly known as NFTs, are tokens of digital assets that represent multiple tangible and intangible assets. The information and ownership of these tokens are stored in blockchains, which are digital blocks that record each and every transaction of the digital asset. The NFTs are stored in digital wallets that are connected to the blockchains, where these tokens are created. The most popular NFTs grant the token holder ownership over popular jpg or png images, but they can also be used for any “collection” items.
   ```

2. **When you buy an NFT, do I automatically get IP rights? Who owns the IP of an NFT?**  当你购买 NFT 时，我会自动获得 IP 权利吗？谁拥有 NFT 的 IP

   ```sh
   我们需要先明确两个概念：creator 和 owner，即创建NFT的人，以及持有NFT的人
   # in order to answer this question, we have to clarify the two important roles: 
   # the creator,  owner
   
   NFT的ownership很明确，但是IP权力一直不明确。
   # Ownership over IP rights of an NFT is not always clearly defined.
   # We know 
   
   
   这个我做了一些调研，调查报告显示，在市值前25的NFT中，几乎没有把IP权力直接给到owner的，creator总是保留IP权力，同时不同的项目给了owner不同的使用license、一共有四种不同的使用license：完全商用、限制性商用、仅限私人使用、CC0。
   
   当然有的项目方在使用权限上也是非常模糊的，如果没有找到明确的terms，那么你要把它当成是仅供个人使用的，否则后面可能会有麻烦。
   
   上述四种使用权限中，最惹人瞩目的是CC0，即creator放弃了所有的权限，对于这个collection而言，任何人都是平等的，无论只有与否，大家都可以直接使用（商用也可以），ownership只能从空投、staking中获得独有权益了。
   
   一个项目如果声明为cc0之后，是没办法撤销的，所以是单向操作，这也是为什么主流的NFT团队不会直接声明他们的nft为CC0，因为这样降低了后续操作的灵活性，如果真的有必要讲权限完全开发给public domain，那么后续creator可以将IP权限声明为CC0，就像moonBird一样。
   
   另外，我在这里可以分享一下我的调研结果，仅供大家参考，可能帮大家从更本质上理解NFT：
   
   1. IP权限和使用权限不同，ownership只有使用权，使用权限可以有creator改变，例如moonbirds，从商用到CC0
   2. 在智能合约里面是不会记录任何使用权限的（上述四种），代码中只会在最上面标注为代码的license，比如MIT
   3. 使用权限是由项目方在链下赋予的，一般可以在官网上查看到，terms
   4. 声明为其他权限之后，IP权限还可以改回来，声明为CC0之后，无法修改
   
   
   
   To begin with, all NFTs offer usage licences, which can be split into four broad categories. 
   1. These are commercial rights, 
   2. limited commercial rights, 
   3. personal use only, 
   4. and creative commons zero(CC0). 
   
   Ownership over the intellectual property of an NFT is not always clearly defined.
   
   Let's understand each licence and how the various NFT collections approach them
   
   NFTs make ownership details extremely clear. When a digital asset is purchased, details of the owner are coded into the token and stored permanently on the blockchain. Therefore, NFTs provide undisputed ownership of digital assets. However, when it comes to usage licences and intellectual property (IP) rights of the said digital asset, things get a bit blurry
   
   
   The confusing question is who then legally owns the copyright of the NFT. The experts in the field say that unless the author transfers copyright ownership to the NFT buyer, it’s legally still the author that owns the intellectual property of the NFT despite the NFT transfer to its new owner. Hence, by default, the intellectual property of the underlying invention or creation of the NFT can in principle always belong to the author if he never explicitly transfers intellectual property ownership to other people, despite the NFT ownership being traded in digital spaces.
   
   
   
   ```

   

3. **Which NFT collections have given IP rights to owners?**  哪些 NFT 集合赋予了所有者 IP 权利？

   ```sh
   NFTs rarely offer intellectual property rights to underlying art, say report
   
   目前我知道的只有明确声明为CC0的项目，如ChainRunners、Mfers、CrypToadz给了所有者IP权力
   
   其他的项目据说：WoW正在尝试给ownership们IP权限，具体不太清楚。
   
   Almost no top NFTs convey IP rights, Galaxy found
   
   In the case of Moonbirds, Galaxy found its switch from commercial use licensing to Creative Commons (CC0) — without community consent — highlights the fact that Moonbirds holders never owned any intellectual property (IP). The parent company behind Moonbirds and Oddities was calling the shots.
   
   World of Women (WoW). 
   
   Galaxy’s report lauded one collection as the only project to attempt to transfer full IP rights to NFT holders: World of Women (WoW).
   
   ```

   

4. **How can NFT and Web3 protocols or tools help transfer IP rights?**  NFT 和 Web3 协议或工具如何帮助转移 IP 权利？（==contentIP==）

   ```sh
   旧：转移nft的owner权限可以做到，转移ip权力如何做到呢，我理解的是owenrship根本没有ip权力
   
   新：他说的不是NFT的IP权力如何转移，而是说NFT如何帮助转移IP权力
   
   # 1. 如果NFT是有权利的（CC0，或者创建的时候，明确有IP的），那么可以帮助转移
   # 2. 如果发型的时候没有赋予IP权力，那么则无法帮助完成IP权力转移。
   
   ```

   

5. **New challenges for IP rights owners?**  知识产权所有者面临的新挑战？

   ```sh
   现在的权限结构其实是让owership玩家非常困惑的，很多人默认以为持有了NFT就拥有了属于这个NFT的一切，而事实并非如此（上面已经论述）
   
   这种IP权限的不确定，是有别于传统IP的，如何找到有效方式消除困惑，是需要解决的挑战之一。
   
   # 你的创作被其他人发行了NFT（电影）
   
   # 如果两个NFT高度相似
   
   These two separate ownership mechanisms (corpus mysticum with the copyright ownership of the art, design, etc. of the NFT and corpus mechanicum with the ownership of the NFT per se) can confuse and complicate the transfer of NFTs’ copyright ownership.
   
   ```

   

6. **Could smart contracts be used for IP agreements?**  智能合约能否用于知识产权协议？

   ```sh
   # 不仅局限于NFT了，这次仅仅说的是智能合约，所以可以把话题扩大来讲
   
   答案是肯定的，目前的IP权限是没有写入智能合约的，而是有链下运营来决定的，我们完全可以把IP权限直接在合约部署的时候就写入代码中
   
   这个理论上一定是可行的，但是这样会让项目方creator失去一定的主动权，也许不利于项目后续的发展，我相信随着行业的发展，以及用户的需求变化，
   
   新的商用模式会发展起来，更多的IP权益会从链下逐步走到链上来。
   
   ```

   

7. **Can NFTs Be Used to Protect Against Counterfeiting?**   NFT 能否用于防伪？

   ```sh
   防伪要看你的定义是什么
   
   如果NFT的防伪指的是项目的真假，owership之间的真实性等，那么防伪是区块链的一部分，而NFT本身就是是区块链的一部分，所以NFT一定是可以防伪的。
   如果NFT的防伪是指背后art的真伪，这个是没法做到的，属于链下范畴了。（A可以盗取B的作品，发NFT）
   ```

   

8. **How can IP assets transform DeFi, DAOs and the metaverse?**   IP 资产如何改变 DeFi、DAO 和元宇宙？

   ```sh
   IP-》影响力-〉生态-》NFT有价值
   	- defi：拓展defi的业务，增加新业务场景，sudoswap，nft借贷等
   	- dao：增强社区粘性，
   	- 元宇宙：
   ```



## 四种使用权限

### 1. 商用Commercial Rights

- NFTs that offer commercial rights allow you to monetise the artwork freely. There is no cap on revenue you can earn on the NFT. You may use the asset in any venue or format for any amount of time. [Azuki](https://opensea.io/collection/azuki) by Chiru Labs, the 9th largest NFT collection by market value, has a licence that grants token holders unlimited monetisation rights. ==无收益上限==
- Other NFT collections that fall into this category are the Bored Apes Yacht Club (BAYC), Bored Ape Kennel Club, Mutant Ape Yacht Club, etc.
- [terms of Azuki](https://www.azuki.com/zh/terms-conditions)
- Terms conditions

### 2. 有限商用Limited Commercial Rights

- As the name suggests, these NFTs offer licences to monetise the artwork, but only up to certain limits. These limits usually pertain to revenue amounts, format and venue restrictions and timeframe capping. For instance, the Doodle NFT collection limits revenues that can be earned through merchandise sales to $100,000. ==有收益上限，很严格==
- [terms of Doodle](https://docs.doodles.app/terms-of-service)

### 3. 个人使用Personal Use Only

- This kind of licence indicates that you are not allowed to monetise the artwork in any way and have limited display rights too. For instance, the terms and conditions of [NBA Top Shot](https://nbatopshot.com/) explicitly mentioned that owners could only use, copy, and display the art for personal or non-commercial use or onward sale.
- Veefriends is another Personal Use Only NFT collection. Its terms and conditions state that "unless otherwise specified, your purchase of a VFNFT does not give you the right to publicly display, perform, distribute, sell or otherwise reproduce the VFNFT or its content for any commercial purpose."
- ==只能展示，不能用于商业用途==
- [terms of NBA](https://nbatopshot.com/terms)
- [terms of VeeFriends](https://veefriends.com/terms-of-use)

### 4. 免费共享Creative Commons Zero

- Creative Commons Zero (CC0) is a licence wherein the copyright holder effectively waives off all its copyright and related rights for an artwork. Such NFTs are then effectively free for use by the public domain. Anyone can use these artworks commercially, alter them and monetise them without permission from or attribution to the original users. Some examples of CC0 NFTs include Chain Runners, Mfers, CrypToadz, etc.
- ==任何人随便用==
- Cc0 basically means that the creator of the artwork/content does not retain any intellectual property (IP). This happens by default after a certain amount of time, but it can also happen if the creator decides to give up their intellectual property right away. You’ve probably heard that something is in the “public domain”, meaning that anyone is free to use that intellectual property to create content. And cc0 is just another way of saying it.
- [terms of ChainRunners](https://www.chainrunners.xyz/xr)（底部有一个声明）
- [Mfers](https://mirror.xyz/sartoshi.eth/QukjtL1076-1SEoNJuqyc-x4Ut2v8_TocKkszo-S_nU) （mirror上有声明）
- [CrypToadz](https://twitter.com/cryptoadzNFT) （twitter上有声明）



## ==使用权限不等于IP权限==（小结）

1. 使用权限和IP权限是不同的，持有IP权限的项目方可以随时修改使用权限（Usage licenses are different from IP rights），比如[Moonbirds](https://nftnow.com/news/moonbirds-just-made-all-their-nfts-public-domain/)
2. NFT的各种使用权限（商用、个人使用、限定商用、CC0）等和代码无关，代码层面，目前只看到代码本身的开源协议，例如MIT
3. 代码层面，只能管理到用户的ownership，所有使用权限、IP权限都是链下的事情（官网声明等）
4. opensea上也没有特别展示（在简介中可能有）
5. 当持有一个NFT的时候，持有人是有一些使用权力的，个人权限，商业权限等，但是IP的权限仍然保留在创造者手里，持有者仅有使用权，如果是CC0的，那么表明任何人都可以有任何使用权（主要是商用），但是IP权限依然保留在创作者手里（除非明确进行了转移）



## 结论

- Each NFT project has different usage licences and very few collections offer IP rights to the NFT holder. Moreover, some projects also carry confusing statements on their websites and terms of ownership. Therefore, it is extremely important to understand the agreement conditions before committing monies to a project.



## 参考链接

1. [Relationship between NFTs and Intellectual Property](https://www.lexology.com/library/detail.aspx?g=e9c8fc34-5858-4390-96df-1015a2c0a3f0)
2. [NFTs rarely offer intellectual property rights to underlying art, say report](https://www.cnbctv18.com/cryptocurrency/nft-rarely-offer-intellectual-property-rights-to-underlying-art-says-report-14576601.htm)
3. 进一步了解cc0:https://creativecommons.org/cc-and-nfts/
4. https://www.coindesk.com/learn/nfts-and-intellectual-property-what-do-you-actually-own/
5. https://palm.io/studio/nft-copyright-ip-rights-cc0/

# 其他

## CC0

- A CC0 (creative commons – no rights reserves) NFT is a form of copyright that enables the creator to allow their NFTs to be owned by others. CC0 means that anyone can use the NFT for commercial purposes in numerous ways without the need to give attribution to the original artist, team, or creator.
- CC0 (just like all CC licenses and tools) applies only to rights under copyright—other rights, such as personality rights, trademark rights, and privacy rights may still be enforced unless explicitly waived using some other mechanism. As the ownership of an NFT linked to a work is not a right held under copyright, the NFT may continue to be held and transferred even when the associated work is released under CC0.
- Unlike term bound, “don't do this' ', “can't do that” limited copyright licenses, CC0 licenses have zero restrictions & are irrevocable once granted. When a project goes CC0, there's no going back. The finality of this license alone is a benefit.
- “==CC0 licenses are too permissive==,” Galaxy said, because it moves the IP fully into the public domain, which means no one truly owns it. T==his makes it “unfeasible for entrepreneurs to integrate NFTs into their businesses due to the lack of legal protections.”== “CC0 许可证过于宽松，”Galaxy 说，因为它将 IP 完全移入公共领域，这意味着没有人真正拥有它。这使得“由于缺乏法律保护，企业家无法将 NFT 整合到他们的业务中
- In a CC0 scenario, everyone has the same IP rights to the art, even if they don’t own the NFT. 
- As stated at the outset, one of the core value propositions and motivators for purchasing or collecting an NFT is to own the associated artwork or IP. In a CC0 scenario, everyone has the same IP rights to the art, even if they don’t own the NFT. With legally defensible protections out the window, the remaining value of owning the NFT has to emerge from token-centric utility, such as gated access, airdrops, staking, or similar chain-dependent activations. So long as the project keeps this incentive shift in mind, the NFT itself remains an attractive opportunity, even without exclusive IP rights. 如开头所述，购买或收集 NFT 的核心价值主张和动机之一是拥有相关的艺术品或 IP。在 CC0 场景中，每个人都对艺术品拥有相同的知识产权，即使他们不拥有 NFT。有了法律上的保护措施，拥有 NFT 的剩余价值必须来自以代币为中心的实用程序，例如门控访问、空投、质押或类似的依赖链的激活。只要项目牢记这种激励转变，即使没有专有知识产权，NFT 本身仍然是一个有吸引力的机会。
- “CC0 licenses are too permissive,” Galaxy said, because it moves the IP fully into the public domain, which means no one truly owns it. This makes it “unfeasible for entrepreneurs to integrate NFTs into their businesses due to the lack of legal protections.”



## WOW

[terms唯一尝试转移IP的NFT Collection](https://worldofwomen.mypinata.cloud/ipfs/QmRPn2jf3u5tc47Z2PDJRbzKZhBUyi4qBABfSVCDWeUBPz)，但是貌似并没有，我看了terms，没见到完全转移的意思。



## PFP

Profile Pic.

## ONE-ONE