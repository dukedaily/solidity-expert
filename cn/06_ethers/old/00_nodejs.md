# nodejs使用es6语法

创建token.js，内容如下

```js
// npm install @alch/alchemy-web3

// alchemy-token-api/alchemy-web3-script.js
import { createAlchemyWeb3 } from "@alch/alchemy-web3";

// Replace with your Alchemy api key:
const apiKey = "-qZ8NcwdvM8gsbxWyFl_Iw9znBN5UV3t";

// Initialize an alchemy-web3 instance:
const web3 = createAlchemyWeb3(
    `https://eth-mainnet.g.alchemy.com/v2/${apiKey}`,
);

let main = async () => {
    // The token address we want to query for metadata:
    const metadata = await web3.alchemy.getTokenMetadata("0xdAC17F958D2ee523a2206206994597C13D831ec7")

    console.log("TOKEN METADATA->");
    console.log(metadata);
}

main()
```

执行命令：

```sh
node token.js
```

报错如下：

```sh
SyntaxError: Cannot use import statement outside a module
    at Object.compileFunction (node:vm:352:18)
    at wrapSafe (node:internal/modules/cjs/loader:1033:15)
    at Module._compile (node:internal/modules/cjs/loader:1069:27)
    at Object.Module._extensions..js (node:internal/modules/cjs/loader:1159:10)
    at Module.load (node:internal/modules/cjs/loader:981:32)
    at Function.Module._load (node:internal/modules/cjs/loader:822:12)
    at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:77:12)
    at node:internal/main/run_main_module:17:47
```

原因：

```sh
在nodejs中使用了es6语法 import
```

**解决办法为1：**

在package.json中增加字段：    "type": "module"，再次执行即可成功！

```js
{
    "dependencies": {
        "@alch/alchemy-web3": "^1.4.2",
        "esm": "^3.2.25"
    },
    "type": "module"
}
```

**解决办法为2：**

将token.js修改为`token.mjs`，直接执行即可

