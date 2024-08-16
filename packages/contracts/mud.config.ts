import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "app",
  enums: {
    Direction: [
      "Up",
      "Down",
      "Left",
      "Right"
    ]
  },
  tables: {
    Character: {
      schema: {
        x: "int32",
        y: "int32",
        owner: "address",
        attackedAt: "uint32",
        isDead: "bool"
      },
      key: ["x", "y"]
    },
    PlayerPrivateState: {
      schema: {
        account: "address",
        commitment: "uint32",
      },
      key: ["account"]
    },
  },
});