

```
circom spawn.circom --r1cs --wasm --sym
node spawn_js/generate_witness.js spawn_js/spawn.wasm input.json witness.wtns
```


```
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup spawn.r1cs pot12_final.ptau spawn_0000.zkey
snarkjs zkey contribute spawn_0000.zkey spawn_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey spawn_0001.zkey verification_key.json
snarkjs zkey export solidityverifier spawn_0001.zkey ../../contracts/src/CircomVerifier.sol
```


```
mkdir ../../../client/public/zk_artifacts/
cp spawn_js/spawn.wasm ../../../client/public/zk_artifacts/
cp spawn_0001.zkey ../../../client/public/zk_artifacts/spawn_final.zkey
```