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

  return {
    spawn, move
  };
}