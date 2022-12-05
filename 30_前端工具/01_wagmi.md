## 基础工具

```sh
# 脚手架
npm i create-react-app

# UI
npm i antd

# 以太坊专用hookup，https://wagmi.sh/
npm i wagmi ethers
```



## 语法

- class extends Component，里面使用在constructor中定义state，可以单独创建，也键值对结构统一创建
- 读取state：this.state.number
- 设置state: this.setState({number: 100})
- 在组件之间传递时，直接在组件后面增加 key=value传递state
- 在组件端接收时，使用参数props进行解构，传递过来的多组state都会统一存储在props中，这是一个json结构。
