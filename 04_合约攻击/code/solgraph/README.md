# solgraph

[![npm version](https://img.shields.io/npm/v/solgraph.svg)](https://npmjs.org/package/solgraph)
[![Build Status](https://travis-ci.org/raineorshine/solgraph.svg?branch=master)](https://travis-ci.org/raineorshine/solgraph)

Generates a [DOT](<https://en.wikipedia.org/wiki/DOT_(graph_description_language)>) graph that visualizes function control flow of a Solidity contract and highlights potential security vulnerabilities.

![Screenshot](https://raw.githubusercontent.com/raineorshine/solgraph/master/example.png)

**Legend:**

- Red: Send to external address
- Blue: Constant function
- Yellow: View
- Green: Pure
- Orange: Call
- Purple: Transfer
- Lilac: Payable

**Generated from contract:**

```js
contract MyContract {
  uint balance;

  function MyContract() {
    Mint(1000000);
  }

  function Mint(uint amount) internal {
    balance = amount;
  }

  function Withdraw() {
    msg.sender.send(balance);
  }

  function GetBalance() constant returns(uint) {
    return balance;
  }
}
```

## Install

```sh
npm install -g solgraph
```

Depending on your permissions, you may need to add the `unsafe-perm` flag:

```sh
sudo npm install -g solgraph --unsafe-perm=true --allow-root
```

## Usage

```sh
solgraph MyContract.sol > MyContract.dot
strict digraph {
  MyContract
  Mint [color=gray]
  Withdraw [color=red]
  UNTRUSTED
  GetBalance [color=blue]
  MyContract -> Mint
  Withdraw -> UNTRUSTED
}
```

You have to have [graphviz](https://graphviz.gitlab.io/download/) installed (`brew install graphviz`) to render the [DOT](<https://en.wikipedia.org/wiki/DOT_(graph_description_language)>) file as an image:

```sh
dot -Tpng MyContract.dot -o MyContract.png
```

A nice example of piping contract source that is in your clipboard through solgraph, dot, and preview: (Use whatever image previewer is available on your system; Preview.app is available on Mac)

```sh
pbpaste | solgraph | dot -Tpng | open -f -a /Applications/Preview.app
```

## Node Module

```js
import { readFileSync } from 'fs'
import solgraph from 'solgraph'

const dot = solgraph(fs.readFileSync('./Simple.sol'))
console.log(dot)
/*
Foo
Bar
Foo -> Bar
*/
```

## License

ISC © [Raine Revere](https://github.com/raineorshine)
