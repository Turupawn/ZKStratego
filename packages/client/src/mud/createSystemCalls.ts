import { getComponentValue } from "@latticexyz/recs";
import { ClientComponents } from "./createClientComponents";
import { SetupNetworkResult } from "./setupNetwork";
import { singletonEntity } from "@latticexyz/store-sync/recs";
import { groth16 } from "snarkjs";
import { getBigInt, hexlify, encodeBytes32String } from "ethers";

function numberToBytes32(num: number): string {
  // Convert the number to a hex string
  let hexString = hexlify("0x12");
  
  // Remove the "0x" prefix
  hexString = hexString.replace("0x", "");
  
  // Pad the hex string to 32 bytes (64 characters) with leading zeros
  const paddedHexString = ethers.utils.hexZeroPad("0x" + hexString, 32);

  return paddedHexString;
}

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { worldContract, waitForTransaction }: SetupNetworkResult,
  { Character }: ClientComponents,
) {
  const spawn = async (x: number, y: number) => {
    const { proof, publicSignals } = await groth16.fullProve(
      {
          character1: 4,
          character2: 1,
          character3: 2,
          character4: 3,
          privateSalt: 123,
          characterReveal: 1,
          valueReveal: 4,
      },
      "./zk_artifacts/reveal.wasm",
      "./zk_artifacts/reveal_final.zkey"
    );
    let commitment : number = publicSignals[0];
    const tx = await worldContract.write.app__spawn([x, y, commitment]);
    await waitForTransaction(tx);
    return getComponentValue(Character, singletonEntity);
  };

  const move = async (x: number, y: number, direction: number) => {
    const tx = await worldContract.write.app__move([x, y, direction]);
    await waitForTransaction(tx);
    return getComponentValue(Character,  singletonEntity);
  }

  const attack = async (fromX: number, fromY: number, toX: number, toY: number, circuitInputs: any) => {

    const { proof, publicSignals } = await groth16.fullProve(circuitInputs,
      "./zk_artifacts/reveal.wasm",
      "./zk_artifacts/reveal_final.zkey"
    );

    console.log(proof)
    console.log(publicSignals)

    let pa = proof.pi_a
    let pb = proof.pi_b
    let pc = proof.pi_c
    pa.pop()
    pb.pop()
    pc.pop()

    console.log(pa)
    console.log(pb)
    console.log(pc)

    const tx = await worldContract.write.app__attack([pa, pb, pc, publicSignals, fromX, fromY, toX, toY]);
    await waitForTransaction(tx);
    return getComponentValue(Character,  singletonEntity);
  }

  return {
    spawn, move, attack
  };
}