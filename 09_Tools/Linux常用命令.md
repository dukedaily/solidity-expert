检查端口存在：

```js
ps -ef | grep 5432

// sudo lsof -i:5432，考虑使用sudo
lsof -i:5432
```



