// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { RevealVerifier } from "../src/RevealVerifier.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

import { VerifierContracts } from "../src/codegen/index.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // ------------------ EXAMPLES ------------------

    // Call increment on the world via the registered function selector
    //uint32 newValue = IWorld(worldAddress).app__increment();
    //console.log("Increment via IWorld:", newValue);

    address revealVerifier = address(new RevealVerifier());
    VerifierContracts.setRevealContractAddress(revealVerifier);

    vm.stopBroadcast();
  }
}
