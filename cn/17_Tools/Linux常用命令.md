检查端口存在：

```js
// first
ps -ef | grep 5432

// second
sudo lsof -i:5432

// third
sudo lsof -i -P -n | grep LISTEN
```



nvm

https://heynode.com/tutorial/install-nodejs-locally-nvm/

```sh
nvm alias default 10.0.0

nvm isntall v16.17.1
nvm use v16.17.1

```

