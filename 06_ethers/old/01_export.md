使用export时，常用code片段：

### 方式一：

1. 文件为：utils.ts，想要导出的内容直接使用export加上花括号，里面是要导出的内容。
2. 在使用的文件中导入方式为：import { getInstance } from './util'

```js
import { getAccountManager, getAuthCenter, getDexOperator, getErc20Token, getFundsProvider, getOpManager } from "../../helpers/contracts-getters"

async function getInstance() {
    const fundsProvider = await getFundsProvider('0x2d63aC5Bf659e68787A0558b27347cD27C68D3De')
    const dexOperator = await getDexOperator('0x0E8bF210F0Bfe85fc2B7C848a047E669Cfb59459')
    const accountManager = await getAccountManager('0x7c0b99fb6F6d7064b5984B411e506E927fa981cC')
    const authCenter = await getAuthCenter('0x3E5487585A4753e20CbA6431Ede73ffaE18c5DCb')
    const opManager = await getOpManager('0x5419FAA010A0F856b21B94ff20A018b515D04EEA')

    let USDT = await getErc20Token('', '0x55d398326f99059fF775485246999027B3197955')
    let BNB = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE'
    let BTCB = await getErc20Token('', '0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c')
    let CAKE = await getErc20Token('', '0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82')
    return {
        fundsProvider, dexOperator, accountManager, authCenter, opManager, USDT, BNB, BTCB, CAKE
    }
}

export {
    getInstance
}
```

### 方式二：

导出时，使用变量，在目的地使用成员形式

```js
// 导出时
export const Utils = {
    getInstance
}

// 使用：
import {Utils} from './util';

async function main() {
	await Utils.getInstance()  
}
```

### 方式三：

1. 使用default，只要没有使用default进行导出，那么在import的地方就需要使用花括号包裹，如果使用default则无需花括号
2. 并且在import的时候名字是可以定义别名的，使用.成员形式进行导出对对象的访问。

```js
export default {
    getInstance
}

// 使用：
import AA from './util';

async function main() {
    await hre.run("set-DRE")
    let { fundsProvider,
        dexOperator,
        accountManager,
        authCenter,
        opManager,
        USDT,
        BNB, BTCB, CAKE
    } = await AA.getInstance()
}
```



## 总结

1. export xxx ,被称为named export, 一个文件可以export 多个name export，在使用的地方，直接使用花括号进行destruction，类似 import {xxx} fro "./kkk"
2. export default yyy，表示这个文件中最重要的导出是yyy，在使用的时候 不需要结构，直接倒入即可，类似import Hello from "./kkk"
