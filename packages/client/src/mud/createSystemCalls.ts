import { getComponentValue } from "@latticexyz/recs";
import { ClientComponents } from "./createClientComponents";
import { SetupNetworkResult } from "./setupNetwork";
import { singletonEntity } from "@latticexyz/store-sync/recs";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { worldContract, waitForTransaction }: SetupNetworkResult,
  { Character }: ClientComponents,
) {
  const spawn = async (x: number, y: number, commitment: number) => {
    const tx = await worldContract.write.app__spawn([x, y, commitment]);
    await waitForTransaction(tx);
    return getComponentValue(Character, singletonEntity);
  };

  const move = async (x: number, y: number, direction: number) => {
    const tx = await worldContract.write.app__move([x, y, direction]);
    await waitForTransaction(tx);
    return getComponentValue(Character,  singletonEntity);
  }

  const attack = async (fromX: number, fromY: number, toX: number, toY: number) => {
    let pa = [1,1];
    let pb = [[1,1],[1,1]];
    let pc = [1,1];
    let publicSignals = [1,2,3,4];
    const tx = await worldContract.write.app__attack([pa, pb, pc, publicSignals, fromX, fromY, toX, toY]);
    await waitForTransaction(tx);
    return getComponentValue(Character,  singletonEntity);
  }

  return {
    spawn, move, attack
  };
}