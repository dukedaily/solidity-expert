# 第1节: Nodejs介绍

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com



为了学习etherjs，我们需要先掌握必要的js知识，大体包括：变量、函数、数组、类、await/async语法、import等，掌握本文内容就足够了（2个小时就能掌握）。

# 一、Node的发展历史和异步IO机制

## 1. 故事的开端

我给大家讲个故事。(京东)

很久很久以前，浏览器只能展示文本和图片，并不能像现在这样有动画，弹窗等绚丽的特效。为了提升浏览器的交互性，Javascript就被设计出来；而且很快统一了所有浏览器，成为了前端脚本	开发的唯一标准。

<img src="https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221123105943035.png" alt="image-20221123105943035" style="zoom:100%;" />



## 2. 浏览器之战

随着互联网的不断普及和Web的迅速发展，几家巨头公司开始了浏览器之战。微软推出了IE系列浏览器，Mozilla推出了Firefox浏览器，苹果推出了Safari浏览器，谷歌推出了Chrome浏览器。其中，微软的IE6由于推出的早，并和Windows系统绑定，在早期成为了浏览器市场的霸主。没有竞争就没有发展。微软认为IE6已经非常完善，几乎没有可改进之处，就解散了IE6的开发团队。而Google却认为支持现代Web应用的新一代浏览器才刚刚起步，尤其是浏览器负责运行JavaScript的引擎性能还可提升10倍，于是自己偷偷开发了一个高性能的Javascript解析引擎，取名V8，并且开源。在浏览器大战中，微软由于解散了最有经验、战斗力最强的浏览器团队，被Chrome远远的抛在身后。。。

<img src="https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221123105957151.png" alt="image-20221123105957151" style="zoom:100%;" />



## 3. Node的诞生

浏览器大战和Node有何关系？

话说有个叫**Ryan Dahl**的歪果仁，他的工作是用C/C++写高性能Web服务。对于高性能，异步IO、事件驱动是基本原则，但是用C/C++写就太痛苦了。于是这位仁兄开始设想用高级语言开发Web服务。他评估了很多种高级语言，发现很多语言虽然同时提供了同步IO和异步IO，但是开发人员一旦用了同步IO，他们就再也懒得写异步IO了，所以，最终，**Ryan**瞄向了JS。因为JavaScript是单线程执行，根本不能进行同步IO操作，只能使用异步IO。

另一方面，因为V8是开源的高性能JavaScript引擎。Google投资去优化V8，而他只需拿来改造一下。

于是在2009年，Ryan正式推出了基于JavaScript语言和V8引擎的开源Web服务器项目，命名为Node.js。虽然名字很土，但是，Node第一次把JavaScript带入到后端服务器开发，加上世界上已经有无数的JavaScript开发人员，所以Node一下子就火了起来。（v8是c++写的，node是改造过的的v8引擎）

![image-20221123110442458](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221123110442458.png)



## 4. 浏览器端JS和Node端JS的区别

相同点就是都使用了Javascript这门语言来开发。

浏览器端的JS，受制于浏览器提供的接口。比如浏览器提供一个弹对话框的Api，那么JS就能弹出对话框。浏览器为了安全考虑，对文件操作，网络操作，操作系统交互等功能有严格的限制，所以在浏览器端的JS功能无法强大，就像是压在五行山下的孙猴子。

==NodeJs完全没有了浏览器端的限制，让Js拥有了文件操作，网络操作，进程操作等功能==，和Java，Python，Php等语言已经没有什么区别了。而且由于底层使用性能超高的V8引擎来解析执行，和天然的异步IO机制，让我们编写高性能的Web服务器变得轻而易举。Node端的JS就像是被唐僧解救出来的齐天大圣一样，法力无边。

![image-20221123110502056](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221123110502056.png)



## 5. NodeJs下载与安装

- 下载地址：<http://nodejs.cn/download/>

- ```
  sudo apt-get install nodejs
  ```

- 安装完毕，在命令行输入：`node -v`查看node的版本，如果能成功输出，证明安装没有问题。

  - node -v: 提供nodejs代码的运行环境
  - npm -v：node包管理工具，类比于apt-get

#   二、ES6常用新语法

Nodejs完全支持ES6语法，本课程的内容，是已经假设你有过一些JavaScript的使用经验的，并不是纯粹的零基础。

![image-20221123110537556](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221123110537556.png)



## 1. ES6新语法

> 什么是ES6? 
>
> [ECMA](https://baike.baidu.com/item/ECMAScript/1889420?fr=aladdin)（European Computer Manufacturers Association）
>
> 由于JavaScript是上个世纪90年代，由**Brendan Eich**在用了10天左右的时间发明的；虽然语言的设计者很牛逼，但是也扛不住"时间紧，任务重"。因此，JavaScript在早期有很多的设计缺陷；而它的管理组织为了修复这些缺陷，会定期的给JS添加一些新的语法特性。JavaScript前后更新了很多个版本，我们要学的是ES6这个版本。
>
> ES6是JS管理组织在2015年发布的一个版本，这个版本和之前的版本大不一样，包含了大量实用的，拥有现代化编程语言特色的内容，比如：**Promise, async/await, class继承**等。因此，我们可以认为这是一个革命性的版本。



## 2. 定义变量

- 使用`const`来定义一个常量，常量也就是不能被修改，不能被重新赋值的变量。
- 使用`let`来定义一个变量，而不要再使用`var`了，因为`var`有很多坑；可以认为`let`就是修复了bug的`var`。比如，var允许重复声明变量而且不报错；var的作用域让人感觉疑惑。
- 最佳实践：优先用`const`，如果变量需要被修改才用`let`；要理解目前很多早期写的项目中仍然是用`var`。

```js
var i = 10;
console.log("var :" , i);

var i = 100;
console.log("var :" , i);


function test () {
    var m = 10;
    console.log("test m :", m);
}

test();
//console.log("test outside :", m);


let j = "hello"
console.log("j :" , j);

j = "HELLO"
console.log("j :" , j);

const k = [1,2,3,4];
console.log("k0 :" , k);

k[0] = 100;
console.log("k1 :" , k);

//k = [4,5,6,7];
//console.log("k2 :" , k)
```




## 3. 解构赋值

> ES6 允许我们按照一定模式，从数组和对象中提取值，对变量进行赋值，这被称为解构（Destructuring）

- 数组的解构赋值

  ```javascript
  const arr = [1, 2, 3] //我们得到了一个数组
  let [a, b, c] = arr //可以这样同时定义变量和赋值
  console.log(a, b, c); // 1 2 3	
  ```

- 对象的解构赋值（常用）

  ```javascript
  const obj = { name: '俊哥',address:'深圳', age: '100'} //我们得到了一个对象
  let {name, age} = obj //可以这样定义变量并赋值
  console.log(name, age); //俊哥 100
  ```

- 函数参数的解构赋值（常用）

  ```javascript
  const person = { name: '小明', age: 11}
  function printPerson({name, age}) { // 函数参数可以解构一个对象
      console.log(`姓名：${name} 年龄：${age}`);
      //console.log("姓名：", name,  "年龄：", age);
  }
  printPerson(person) // 姓名：小明 年龄：11
  ```


## 4. 函数扩展

> ES6 对函数增加了很多实用的扩展功能。

- 参数默认值，从ES6开始，我们可以为一个函数的参数设置默认值， go语言有默认值吗？

  ```javascript
  function foo(name, address = '深圳') {
      console.log(name, address);
  }
  foo("小明") // address将使用默认值
  foo("小王", '上海') // address被赋值为'上海'
  ```

- 箭头函数，将`function`换成`=>`定义的函数，[就是箭头函数](https://segmentfault.com/a/1190000009410939)

- 只适合用于普通函数，不要用在构造函数，不要用在成员函数，不要用着原型函数

  ```javascript
  function add(x, y) {
      return x + y
  }
  //演示自执行函数
  //函数也是变量，可以赋值
  // 这个箭头函数等同于上面的add函数
  (x, y) => x +y;
  // 如果函数体有多行，则需要用大括号包裹
  (x, y) => {
      if(x >0){
          return x + y
      }else {
          return x - y
      }
  }
  ```



## 5. Class继承

>由于==js一开始被设计为函数式语言==，万物皆函数。所有对象都是从函数原型继承而来，通过继承某个函数的原型来实现对象的继承。但是这种写法会让新学者产生疑惑，并且和传统的OOP语言差别很大。ES6 封装了class语法来大大简化了对象的继承。

```javascript
class Person {
    constructor(name, age){
        this.name = name
        this.age = age
    }
    // 注意：没有function关键字
    sayHello(){
        console.log(`大家好，我叫${this.name}`);
    }
}

class Man extends Person{
    constructor(name, age){
        super(name, age)
    }
    //重写父类的方法
    sayHello(){
        console.log('我重写了父类的方法！');
    }
}
let p = new Person("小明", 33) //创建对象
p.sayHello() // 调用对象p的方法，打印 大家好，我叫小明
let m = new Man("小五", 33)
m.sayHello() // 我重写了父类的方法！
```



## 6. 总结

ES6 的新语法有很多，有人将它总结为了一本书。当然，ES6提出的只是标准，各大浏览器和node基本实现了90%以上的新特性，极其个别还没有实现。我们目前讲的是最基本的一些语法，由于你们还未了解同步和异步的概念；Promise和async/await的内容将会在后面的课程中讲解。



## 7. 学习资源

**ES6 入门教程**：http://es6.ruanyifeng.com/

**各大浏览器的支持程度**：http://kangax.github.io/compat-table/es6/



# 三、NodeJS的事件驱动和异步IO

NodeJS在用户代码层，==只启动一个线程来运行用户的代码====（go语言？）==。每当遇到耗时的IO操作，比如文件读写，网络请求等，nodejs会将这些耗时操作丢给底层的事件循环去执行，而自己则不会等待，继续执行下面的代码。当底层的事件循环执行完耗时IO时，会执行我们的回调函数来作为通知。这个过程就是异步处理过程。

## 1. 同步vs异步

* 同步就是你去银行排队办业务，排队的时候啥也不能干(阻塞)。

* 异步就是你去银行用取号机取了一个号，此时你可以自由的做其他事情，**到你的时候会用大喇叭对你进行事件通知**。而银行系统相当于底层的事件循环，不断的处理耗时的业务(IO)。

注意，无论你感觉系统返回的有多快，那它都是异步的。

## 2. 回调函数callback

- Node.js 异步编程的直接体现就是回调。
- 回调函数在完成任务后就会被调用，Node 使用了大量的回调函数，Node 所有 API 都支持回调函数。
- 回调函数一般作为参数的==最后一个参数出现==。

回调函数使用场景：我们可以一边读取文件，一边执行其他命令，在文件读取完成后，我们将文件内容作为回调函数的参数返回。这样在执行代码时就没有阻塞或等待文件 I/O 操作。这就大大提高了 Node.js 的性能，可以处理大量的并发请求。

```
function foo1(name, age, callback) { }
function foo2(value, callback1, callback2) { }
```

## 3. 同步调用（阻塞）

请事先在当前目录下准备文件"input.txt"，写入任意数据。

```js
var fs = require("fs");

var data = fs.readFileSync('input.txt');

console.log(data.toString());
console.log("程序执行结束!");
```

## 4. 异步调用（非阻塞）

```js
var fs = require("fs");

//error first callback
fs.readFile('input.txt', function (err, data) {
    if (err) return console.error(err);
    console.log(data.toString());
});

console.log("程序执行结束!");
```

demo

```js
//node内置的读取文件的模块
let fs = require('fs')

let filename = '1.txt'

//先测试同步读取文件
let data = fs.readFileSync(filename, 'utf-8')
console.log('同步读取文件内容 data :', data)

//同步执行：
//1. 同步读取文件时，无需回调函数，返回值就是读取的数据内容
//2. 主线程阻塞在读取函数这里，一直到读取完成后，才继续向下执行
//3. 慢，效率低


//异步执行：
//1. 需要注册一个回调函数
//2. 主线发现是异步调用时，直接把任务丢给nodejs的后台线程执行， 主线程继续向下执行其他代码
//3. 当后台执行完成时，会通知通过回调函数通知主线程，主线程执行。



//测试异步读取文件
fs.readFile(filename, 'utf-8', /*回调函数*/ function (err, data) {
    if (err) {
        console.log('读取文件出错:', err)
        return
    }

    console.log('异步读取文件数据:', data)
})

console.log('异步读取数据2222!')
```



## 5. 异步调用原理（了解即可）

### - 事件处理机制

==Node.js==在主线程里维护一个事件队列，当接收到一个请求之后，会将这个请求当成一个事件放在事件队列中，然后继续接收其他请求。当主线程空闲时，就会开始遍历这个队列。检查队列中是否有要处理的事件，如果需要处理的事件不是I/O任务，那么主线程亲自处理，通过回调函数，返回到上层调用。

如果是I/O任务，就从线程池里拿一个线程处理这个事件，并且指定回调函数，然后继续循环处理队列中的其他事件。

### - 事件循环原理

当线程中的IO任务完成之后，会调用回调函数，并且将这个完成的事件放到事件队列的尾部，等待事件循环，当主线程再次循环到这个事件时，就会处理它，并且返回给上层调用，这个过程就是事件循环（Event Loop）。

### - node.js运行原理图

![image-20221123110700503](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221123110700503.png)



从左到右，从上到下，node.js被分为四层：应用层、v8引擎层、node api层、LIBUV层。

- 应用层：JavaScript交互层，常见的就是Node.js的模块，如"http"， "fs"。
- V8引擎层：利用v8引擎来解析JavaScript语法，进而与下层api交互。
- Node API层：为上层模块提供系统调用，一般由C语言来实现，和操作系统进行交互。
- LIBUV层：是跨平台的底层封装，实现了事件循环，文件操作等，是Node.js实现异步的核心。



### - 思维误区

node.js内部是通过线程池来完成I/O操作的，但是LIBUV层对不同平台的差异实现了统一的封装。

Node.js的单线程是指JavaScript代码运行在单线程中，并不是说Node.js是单线程的，Node.js是多线程的平台，但是对于JavaScript的处理是单线程的。



### - Node.js的特点和适用性

- Node.js在处理I/O任务的时候，会把任务交给线程池来处理，高效简单，因此==Node.js适合用于处理I/O密集型的任务，但是不适合处理CPU密集型的任务==，这是因为对于非I/O任务Node.js都是通过主线程亲自计算的，前面的任务没有处理完的情况下就会导致后来的任务堆积，就会出现响应缓慢的情况。即使是多核CPU在使用Node.js处理非I/O任务的时候，由于Node.js只有一个事件循环队列，所以只占用一个CPU内核，但是其他的内核都会处于空闲状态，因此会造成响应缓慢，CPU资源浪费的情况，所以Node.js不适合用于处理CPU密集型的任务。那这个功能就交由C++，C，Go，Java这些语言实现。像淘宝，京东这种大型网站绝对不是一种语言就可以实现的。语言只是工具，让每一种语言做它最擅长的事，才能构建出稳定，强大的系统。

- Node.js还有一个优点是线程安全，单线程的JavaScript运行方式保证了线程的安全，不用担心同一个变量被多个线程进行读写造成程序崩溃。同时也免去了在多线程编程中忘记对变量加锁或者解锁造成隐患。


## 6. NodeJs能做什么？

![image-20221123110755338](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221123110755338.png)

# 四、常用数据类型

## 1. Buffer

JavaScript 语言自身只有字符串数据类型，没有二进制数据类型，因此在 Node.js中，定义了一个 Buffer 类，该类用来创建一个专门存放二进制数据的缓存区。

```js
console.log("=============== buffer 与 编码");
const buf = Buffer.from('runoob', 'ascii');
console.log(buf);
console.log(buf.toString());
console.log(buf.toString('utf8'));
console.log(buf.toString('hex'));


console.log("=============== 创建buffer")
//指定长度，默认值为buffer，string，number
const buf1 = Buffer.alloc(10, 'test')
console.log("buf1 " + buf1)

//数组，buffer，string
let buffer = Buffer.from([1, 2,3,4])

console.log(buffer)
console.log(buffer.toString())
console.log(buffer.toJSON())

console.log("=============写入buffer")

let buf2 = Buffer.alloc(152);
let len = buf2.write('hello world!')
console.log("len : " + len);
```

## 2. 事件

Node.js 有多个内置的事件，我们可以通过引入 events 模块，并通过实例化 EventEmitter 类来绑定和监听事件。

```js
let event = require('events');

 
//创建event
var eventEmitter = new event.EventEmitter();

//绑定事件
//名字，响应函数
eventEmitter.on('eat', function(){
    console.log("begin to eat!");
    eventEmitter.emit('drink', 'beer');
})

//绑定多个事件
eventEmitter.on('drink', function(what){
    console.log("begin to drink :", what);
    eventEmitter.emit('think');
})

console.log("before eat!");

//触发事件
let test = ()=> {
    eventEmitter.emit('eat');
}

function thinkHandler(){
    console.log('who am I!');
}

//必须写处理函数，否则抛异常
//eventEmitter.addListener('think');
eventEmitter.addListener('think',thinkHandler);
eventEmitter.removeListener('think', thinkHandler);
eatCount = eventEmitter.listenerCount('eat');
console.log("eat count :" +eatCount);


test();
```



==EventEmitter一般不会单独使用，它是基类，各个模块继承自EventEmitter，例如fs，http等。==

==打开文件，发送请求都是一个事件，都有触发的名字和处理函数。==

# 五、常用模块

## 1.模块系统（exports，require）

为了让Node.js的文件可以相互调用，Node.js提供了一个简单的模块系统

一个文件就是一个模块，使用export关键字实现

```js
//hello.js
let Hello = () => {
    console.log("hello world!")
}
module.exports = Hello;
```

有导出才有导入，两者一定是配合使用的。

```js
//main.js 
var Hello = require('./hello'); 
Hello();
```



## 2. 全局变量

> 全局变量是指我们在任何js文件的任何地方都可以使用的变量。

- `__dirname`：当前文件的目录
- `__filename`：当前文件的绝对路径
- `console`：控制台对象，可以输出信息
- `process`：进程对象，可以获取进程的相关信息，环境变量等
- `setTimeout/clearTimeout`：延时执行
- `setInterval/clearInterval`：定时器



```js

let array = [1,2,3,4];
console.table(array);
console.log(array);


let obj = {name : 'lily', age : 20, address : 'Shenzhen'};
console.table(obj);

console.table("hello world!");


console.log(__dirname)
console.log(__filename)



let argv = process.argv;

console.table(argv);

argv.forEach((value, index) => {
    console.log(index, value);
})


let t1 = setTimeout(function () {
   console.log('帅不过三秒');
   clearInterval(t2);
}, 3000);


let t2 = setInterval(function () {
   console.log("======= 1s 又 1s ")
    //clearTimeout(t1);
}, 1000);
```



## 3. path[模块](http://www.runoob.com/nodejs/nodejs-path-module.html)

> /Users/duke/go/src/01_授课代码/01_shanghai_1/04_nodeCode/06-require.js
>
> ​	

> /Users/duke/go/src/01_授课代码 + xxxx + "/xxxx/" + "/" + 
>
> /Users/duke/go/src/01_授课代码/01_shanghai_1//04_nodeCode///06-require.js
>
> path模块供了一些工具函数，用于处理文件与目录的路径

- `path.basename`：返回一个路径的最后一部分
- `path.dirname`：返回一个路径的目录名
- `path.extname`：返回一个路径的扩展名
- `path.join`：用于拼接给定的路径片段   
- `path.normalize`：将一个路径正常化
- `path.resolve([from ...], to)`  基于当前的执行目录，返回一个绝对路径，退一层演示



```js
var path = require("path");

// 格式化路径
console.log('normalization : ' + path.normalize('/test/test1//2slashes/1slash/tab/..'));

// 连接路径
console.log('joint path : ' + path.join('/test', 'test1', '2slashes/1slash', 'tab', '..'));

// 转换为绝对路径
console.log('resolve : ' + path.resolve('main.js'));

// 路径中文件的后缀名
console.log('ext name : ' + path.extname('main.js'));
```



## 4. fs模块

> 文件操作相关的模块

- `fs.stat/fs.statSync`：访问文件的元数据，比如文件大小，文件的修改时间


- `fs.readFile/fs.readFileSync`：异步/同步读取文件

- `fs.writeFile/fs.writeFileSync`：异步/同步写入文件

- `fs.readdir/fs.readdirSync`：读取文件夹内容

- `fs.unlink/fs.unlinkSync`：删除文件

- `fs.rmdir/fs.rmdirSync`：只能删除空文件夹，思考：如何删除非空文件夹？

  > 使用`fs-extra` 第三方模块来删除。

- `fs.watchFile`：监视文件的变化

```js
let fs = require('fs')

let filename = '1.txt'
let data = fs.readFileSync(filename)

console.log('data :', data.toString())
console.log('读取结束!')

fs.writeFileSync('./2.txt', data.toString())
console.log('同步写结束!')


fs.writeFile('./3.txt', data.toString(), function (err) {
    if (err) {
        return
    }

    console.log('异步写文件成功!')
})

console.log('异步写还没成功...')

fs.stat('./1.txt', function (err, stat) {
    console.log('isFile :', stat.isFile())
    console.log('isDir :', stat.isDirectory())
})
```



## 5. [stream](http://nodejs.cn/api/stream.html)

>  流（stream）是一种在 Node.js 中处理流式数据的抽象接口（基类），分为四种类型：可读、可写、或是可读写。 所有的流都是 [`EventEmitter`](http://nodejs.cn/s/pGAddE) 的实例。



### - 有四种流类型

- **Readable** - 可读操作（例如：fs.createReadStream()）。
- **Writable** - 可写操作。（例如：fs.createWriteStream()）。
- **Duplex** - 可读可写操作.(例如：net.Socket)。
- **Transform** - 操作被写入数据，然后读出结果。（例如：zlib.createDefate()）。



### - 常用事件

所有的 Stream 对象都是 ==EventEmitter== 的实例。常用的事件有：

- **data** - 当有数据可读时触发。
- **end** - 没有更多的数据可读时触发。
- **error** - 在接收和写入过程中发生错误时触发。
- **finish** - 所有数据已被写入到底层系统时触发。



### - 操作大文件

> 传统的`fs.readFile`在读取小文件时很方便，因为它是一次把文件全部读取到内存中；假如我们要读取一个3G大小的电影文件，那么内存不就爆了么？node提供了流对象来读取大文件。
>
> 流的方式其实就是把所有的数据分成一个个的小数据块（chunk），一次读取一个chunk，分很多次就能读取特别大的文件，写入也是同理。这种读取方式就像水龙头里的水流一样，一点一点的流出来，而不是一下子涌出来，所以称为流。



```js
const fs = require('fs')
const path = require('path')

// fs.readFile('bigfile', (err, data)=>{
//     if(err){
//         throw err;
//     }
//     console.log(data.length);
// })

// 需求复制一份MobyLinuxVM.vhdx文件，简写为pipe，on效果一致
const reader = fs.createReadStream('MobyLinuxVM.vhdx')
const writer = fs.createWriteStream('MobyLinuxVM-2.vhdx')
// let total = 0
// reader.on('data', (chunk)=>{
//     total += chunk.length
//     writer.write(chunk)
// })
// reader.on('end',()=>{
//     console.log('总大小：'+total/(1024*1024*1024));
// })
reader.pipe(writer);
```

**任务：用以下知识点完成大文件的拷贝。**

- `fs.createReadStream/fs.createWriteStream`
- `reader.pipe(writer)`

![image-20221123111222415](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221123111222415.png)



## 6. Promise和asnyc/await

我们知道，如果我们以同步的方式编写耗时的代码，那么就会阻塞JS的单线程，造成CPU一直等待IO完成才去执行后面的代码；而CPU的执行速度是远远大于硬盘IO速度的，这样等待只会造成资源的浪费。异步IO就是为了解决这个问题的，异步能尽可能不让CPU闲着，它不会在那等着IO完成；而是传递给底层的事件循环一个函数，自己去执行下面的代码。等磁盘IO完成后，函数就会被执行来作为通知。

虽然异步和回调的编程方式能充分利用CPU，但是当代码逻辑变的越来越复杂后，新的问题出现了。请尝试用异步的方式编写以下逻辑代码：

> 先判断一个文件是文件还是目录，如果是目录就读取这个目录下的文件，找出结尾是txt的文件，然后获取它的文件大小。

恭喜你，当你完成上面的任务时，你已经进入了终极关卡：**Callback hell回调地狱!**

![image-20221123111309129](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221123111309129.png)



为了解决**Callback hell**的问题，`Promise`和`async/await`诞生。

- `promise`的作用是对异步回调代码包装一下，把原来的一个回调函数拆成2个回调函数，这样的好处是可读性更好。语法如下：

  语法注意：**Promise内部的resolve和reject方法只能调用一次，调用了这个就不能再调用了那个；如果调用，则无效。**

  ```javascript
  let fs = require('fs')
  
  
  //想把异步读取文件的过程封装成一个promise
  let readFilePromise = new Promise(function (resolve/*成功时调用*/, reject/*失败时调用*/) {
  
      fs.readFile('./1.txt', 'utf-8', /*回调函数*/ function (err, data) {
          if (err) {
              // console.log('读取文件出错:', err)
              // return
              reject(err)
          }
  
          // console.log('异步读取文件数据:', data)
          resolve(data)
      })
  })
  
  
  //第一次改写，使用then方式调用
  readFilePromise.then(res => {
      console.log('data :', res)
  }).catch(err => {
      console.log(err)
  })
  ```

  

- `async/await`的作用是直接**将Promise异步代码变为同步的写法，注意，代码仍然是异步的**。这项革新，具有革命性的意义。

  语法要求：

  - `await`只能用在`async`修饰的方法中，但是有`async`不要求一定有`await`。
  - `await`后面只能跟`async`方法和`promise`。



  功能需求：写一个函数，读取，写入，返回文件状态，传统写法如下：

  ```javascript
  let fs = require('fs')
  
  //解决办法：把每一个异步函数都封装成一个pomise
  let checkStat1 = () => {
      fs.readFile('./1.txt', 'utf-8', function (err, data) {
          console.log('读取文件: ', data)
  
          fs.writeFile('./2.txt', 'utf-8', function (err) {
              if (err) {
                  return
              }
  
              console.log('写文件成功!')
  
              fs.stat('./2.txt', function (err, stat) {
                  if (err) {
                      return
                  }
                  console.log('文件状态:', stat)
                  return stat
              })
          })
      })
  }
  
  // checkStat1()
  ```

promise写法如下：

```js
let fs = require('fs')

//解决办法：把每一个异步函数都封装成一个pomise
let readFilePromise = () => {
    return new Promise((resolve, reject) => {
        try {
            fs.readFile('./1.txt', 'utf-8', function (err, data) {
                console.log('读取文件: ', data)
                resolve(data)
            })
        } catch (e) {
            reject(e)
        }
    })
}

let writeFilePromise = (data) => {
    return new Promise((resolve, reject) => {
        fs.writeFile('./2.txt', data, 'utf-8', function (err) {
            if (err) {
                reject(err)
            }
            resolve('写入成功!')
        })
    })
}

let statPromise = () => {
    return new Promise((resolve, reject) => {
        fs.stat('./2.txt', function (err, stat) {
            if (err) {
                reject(err)
            }
            // console.log('文件状态:', stat)
            resolve(stat)
        })
    })
}

//如果想使用async，await，promise，
//调用函数的外面修饰为async
//promise函数前面加上await

let checkStat2 = async () => {
    try {
        let data = await readFilePromise()

        let res = await writeFilePromise(data)
        console.log('res :', res)

        let stat = await statPromise()
        console.log('stat:', stat)

    } catch (e) {
        console.log(e)
    }
}

checkStat2()
console.log('333333333')
```



**异步代码的终极写法：**

1. 先使用`promise`包装异步回调代码，可使用node提供的`util.promisify`方法；
2. 使用`async/await`编写异步代码。

![image-20221123111348473](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221123111348473.png)



# ==六、NPM介绍==

![image-20221123111402999](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221123111402999.png)

- ### npm是Nodejs自带的包管理器，当你安装Node的时候就自动安装了npm。
- 当我们想使用一个功能的时候，而Node本身没有提供，那么我们就可以从npm上去搜索并下载这个模块。
- 每个开发语言都有自己的包管理器，比如，java有maven，python有pip。
- npm的海量模块，使得我们开发复杂的NodeJs的程序变得更为简单。

检测安装情况

```
[duke ~]$ npm -v
6.2.0
[duke ~]$ 
```

### - 使用淘宝NPM镜像

- 国内直接使用 npm 的官方镜像是非常慢的，这里推荐使用淘宝 NPM 镜像。
- 淘宝 NPM 镜像是一个完整 npmjs.org 镜像，你可以用此代替官方版本(只读)，
- 同步频率目前为 10分钟 一次以保证尽量与官方服务同步。
- 可以使用淘宝定制的 cnpm (gzip 压缩支持) 命令行工具代替默认的 npm。



### - 常用命令

```js
# 在项目中初始化一个 package.json 文件
# 凡是使用 npm 来管理的项目都会有这么一个文件
npm init

# 跳过向导，快速生成 package.json 文件
# 简写是 -y
npm init --yes

# 一次性安装 dependencies 中所有的依赖项
# 简写是 npm i
npm install

# 安装指定的包，可以简写为 npm i 包名
# npm 5 以前只下载，不会保存依赖信息，如果需要保存，则需要加上 `--save` 选项
# npm 5 以后就可以省略 --save 选项了
npm install 包名

# 一次性安装多个指定包
npm install 包名 包名 包名 ...

# 安装指定版本的包
npm install 包名@版本号

npm install web3@0.20

# 卸载指定的包
npm uninstall 包名

# 安装全局包
npm install --global 包名

# 查看包信息
npm view 包名

# 查看使用帮助
npm help

# 查看某个命令的使用帮助
# 例如我忘记了 uninstall 命令的简写了，这个时候，可以输入 `npm uninstall --help` 来查看使用帮助
npm 命令 --help

# 查看 npm 配置信息
npm config list
```

### - 设置淘宝镜像

```sh
npm config set registry https://registry.npm.taobao.org
```



常见错误：

```js
json parse faild }....@solc
```

解决办法:

```js
npm cache clean --force
```



### ==- 全局安装目录==

```js
mac : /usr/local/Cellar/node/10.11.0/bin
```





## 4. 交互式解释器

### - 简单计算

```sh
$ node
> 1 +4
5
> 5 / 2
2.5
> 3 * 6
18
> 4 - 1
3
> 1 + ( 2 * 3 ) - 4
3
>
```

### - 使用变量

不用变量时直接输出，使用时被变量接收

```shell
$ node
> x = 10
10
> var y = 10
undefined
> x + y
20
> console.log("Hello World")
Hello World
undefined
```

### - 下划线(_)变量

你可以使用下划线(_)获取上一个表达式的运算结果：

```shell
$ node
> var x = 10
undefined
> var y = 20
undefined
> x + y
30
> var sum = _
undefined
> console.log(sum)
30
undefined

```
