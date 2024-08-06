1. Error: Deploying program failed: RPC response error -32002: Transaction simulation failed: Error processing Instruction 0: account data too small for instruction [3 log messages]

![image-20240724231743191](./assets/image-20240724231743191.png)

**Solution**:

```sh
# solana program extend <ProgramId> <Number of ByteCode>
solana program extend dnf7hYRGW5aJSW1LTBWJxgyBJFUgBzVdHfTM87ai6uB 20000
```

2. error: package `solana-program v1.18.18 cannot be built because it requires rustc 1.75.0

![image-20240720105510491](./assets/image-20240720105510491.png)

**Solution:**

```sh
# solana-install init <version> 
# 1.18.18 should equal to the error message: `solana-program v1.18.181`
solana-install init 1.18.18
```

