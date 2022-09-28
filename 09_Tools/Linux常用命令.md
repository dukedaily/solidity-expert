检查端口存在：

```js
// first
ps -ef | grep 5432

// second
sudo lsof -i:5432

// third
sudo lsof -i -P -n | grep LISTEN
```

