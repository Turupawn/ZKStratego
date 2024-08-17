## Reveal

```
cd packages/zk/circuits/reveal
```

```
circom reveal.circom --r1cs --wasm --sym
node reveal_js/generate_witness.js reveal_js/reveal.wasm input.json witness.wtns
```


```
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup reveal.r1cs pot12_final.ptau reveal_0000.zkey
snarkjs zkey contribute reveal_0000.zkey reveal_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey reveal_0001.zkey verification_key.json
snarkjs zkey export solidityverifier reveal_0001.zkey ../../../contracts/src/RevealVerifier.sol
```


```
mkdir ../../../client/public/zk_artifacts/
cp reveal_js/reveal.wasm ../../../client/public/zk_artifacts/
cp reveal_0001.zkey ../../../client/public/zk_artifacts/reveal_final.zkey
```

Now open RevealVerifier.sol and set the contract name to RevealVerifier.


## Defend

```
cd packages/zk/circuits/defend
```

```
circom defend.circom --r1cs --wasm --sym
node defend_js/generate_witness.js defend_js/defend.wasm input.json witness.wtns
```


```
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup defend.r1cs pot12_final.ptau defend_0000.zkey
snarkjs zkey contribute defend_0000.zkey defend_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey defend_0001.zkey verification_key.json
snarkjs zkey export solidityverifier defend_0001.zkey ../../../contracts/src/DefendVerifier.sol
```


```
mkdir ../../../client/public/zk_artifacts/
cp defend_js/defend.wasm ../../../client/public/zk_artifacts/
cp defend_0001.zkey ../../../client/public/zk_artifacts/defend_final.zkey
```

Now open DefendVerifier.sol and set the contract name to DefendVerifier.