import { Has, defineEnterSystem, defineExitSystem, defineSystem, getComponentValueStrict, getComponentValue } from "@latticexyz/recs";
import { PhaserLayer } from "../createPhaserLayer";
import { 
  pixelCoordToTileCoord,
  tileCoordToPixelCoord
} from "@latticexyz/phaserx";
import { TILE_WIDTH, TILE_HEIGHT, Animations, Directions } from "../constants";

function decodePosition(hexString) {
    if (hexString.startsWith('0x')) {
        hexString = hexString.slice(2);
    }

    const halfLength = hexString.length / 2;
    const firstHalfHex = hexString.slice(0, halfLength);
    const secondHalfHex = hexString.slice(halfLength);

    const firstHalfInt32 = getSignedInt32(firstHalfHex);
    const secondHalfInt32 = getSignedInt32(secondHalfHex);

    return { x: firstHalfInt32, y: secondHalfInt32 };
}

function getSignedInt32(hexStr) {
    const int32Value = parseInt(hexStr.slice(-8), 16);

    if (int32Value > 0x7FFFFFFF) {
        return int32Value - 0x100000000;
    }
    return int32Value;
}

function encodePosition(x: number, y: number): string {
    const xHex = int256ToHex(x);
    const yHex = int256ToHex(y);

    // Concatenate the two 32-byte hex values to form a 64-byte hex string
    return '0x' + xHex + yHex;
}

function int256ToHex(value: number): string {
    // If the value is negative, convert it to a 256-bit unsigned integer
    if (value < 0) {
        value = BigInt('0x10000000000000000000000000000000000000000000000000000000000000000') + BigInt(value);
    } else {
        value = BigInt(value);
    }

    // Convert the integer to a hexadecimal string, ensuring it has 64 characters (256 bits)
    let hexStr = value.toString(16);
    while (hexStr.length < 64) {
        hexStr = '0' + hexStr;
    }

    return hexStr;
}

export const createMyGameSystem = (layer: PhaserLayer) => {
  const {
    world,
    networkLayer: {
      components: { Character },
      systemCalls: { spawn, move }
    },
    scenes: {
        Main: { objectPool, input }
    }
  } = layer;

  let startPoint: { x: number; y: number } | null = null;
  let draggedEntity: string | null = null;
  
  // Declare the line objects
  let arrowLine1 = objectPool.get("ArrowLine1", "Line");
  let arrowLine2 = objectPool.get("ArrowLine2", "Line");
  let arrowLine3 = objectPool.get("ArrowLine3", "Line");

  input.pointerdown$.subscribe((event) => {
    const { worldX, worldY } = event.pointer;
    const player = pixelCoordToTileCoord({ x: worldX, y: worldY }, TILE_WIDTH, TILE_HEIGHT);

    if (player.x === 0 && player.y === 0) return;

    let coordinates = pixelCoordToTileCoord({ x: worldX, y: worldY }, TILE_WIDTH, TILE_HEIGHT);
    let encodedPosition = encodePosition(coordinates.x, coordinates.y);
    
    const character = getComponentValue(Character, encodedPosition);

    if (character) {
        startPoint = { x: worldX, y: worldY };
        draggedEntity = `${player.x}-${player.y}`;
    } else {
        spawn(player.x, player.y, 123);
    }
  });

  input.pointermove$.subscribe((event) => {
    if (startPoint && draggedEntity) {
        const { worldX, worldY } = event.pointer;

        // Draw the main line
        arrowLine1.setComponent({
          id: "line",
          once: (line) => {
            line.visible = true;
            line.isStroked = true;
            line.setFillStyle(0xff00ff);
            line.geom.x1 = startPoint.x;
            line.geom.y1 = startPoint.y;
            line.geom.x2 = worldX;
            line.geom.y2 = worldY;
          },
        });
        
        // Draw an arrowhead effect at the end point
        const arrowLength = 20;
        const angle = Math.atan2(worldY - startPoint.y, worldX - startPoint.x);

        arrowLine2.setComponent({
          id: "line",
          once: (line) => {
            line.visible = true;
            line.isStroked = true;
            line.setFillStyle(0x00ff00);
            line.geom.x1 = worldX;
            line.geom.y1 = worldY;
            line.geom.x2 = worldX - arrowLength * Math.cos(angle - Math.PI / 6);
            line.geom.y2 = worldY - arrowLength * Math.sin(angle - Math.PI / 6);
          },
        });

        arrowLine3.setComponent({
          id: "line",
          once: (line) => {
            line.visible = true;
            line.isStroked = true;
            line.setFillStyle(0x00ff00);
            line.geom.x1 = worldX;
            line.geom.y1 = worldY;
            line.geom.x2 = worldX - arrowLength * Math.cos(angle + Math.PI / 6);
            line.geom.y2 = worldY - arrowLength * Math.sin(angle + Math.PI / 6);
          },
        });
    }
  });

  input.pointerup$.subscribe((event) => {
    if (startPoint && draggedEntity) {
        
      const { worldX, worldY } = event.pointer;
      const character = objectPool.get(draggedEntity, "Sprite");

      const startTile = pixelCoordToTileCoord(startPoint, TILE_WIDTH, TILE_HEIGHT);
      const endTile = pixelCoordToTileCoord({ x: worldX, y: worldY }, TILE_WIDTH, TILE_HEIGHT);

      const direction = calculateDirection(startTile, endTile);

      console.log(startTile.x)
      console.log(startTile.y)
      console.log(endTile)
      console.log(direction)
      if (direction != null) {
        move(startTile.x, startTile.y, direction);
        console.log(`Moved character from (${startTile.x}, ${startTile.y}) to (${endTile.x}, ${endTile.y}) in direction ${direction}`);
      }

      startPoint = null;
      draggedEntity = null;
    }
  });

  defineEnterSystem(world, [Has(Character)], ({ entity }) => {
    const characterObj = objectPool.get(entity, "Sprite");
    characterObj.setComponent({
      id: 'animation',
      once: (sprite) => {
        sprite.play(Animations.Unknown);
      }
    });
  });
  
  defineExitSystem(world, [Has(Character)], ({ entity }) => {
    objectPool.remove(entity);
  });

  defineSystem(world, [Has(Character)], ({ entity }) => {
    const character = getComponentValue(Character, entity);
    if(!character)
        return;
    const pixelPosition = tileCoordToPixelCoord(decodePosition(entity), TILE_WIDTH, TILE_HEIGHT);

    const characterObj = objectPool.get(entity, "Sprite");

    if (character.isDead) {
      characterObj.setComponent({
        id: 'animation',
        once: (sprite) => {
          sprite.play(Animations.Dead);
        }
      });
    }

    characterObj.setComponent({
      id: "position",
      once: (sprite) => {
        sprite.setPosition(pixelPosition.x, pixelPosition.y);
      }
    });

    arrowLine1.setComponent({
      id: "line",
      once: (line) => {
        line.visible = false;
      },
    });
    
    arrowLine2.setComponent({
      id: "line",
      once: (line) => {
        line.visible = false;
      },
    });

    arrowLine3.setComponent({
      id: "line",
      once: (line) => {
        line.visible = false;
      },
    });
  });

  function calculateDirection(start: { x: number, y: number }, end: { x: number, y: number }) {
    if (end.y < start.y) return Directions.UP;
    if (end.y > start.y) return Directions.DOWN;
    if (end.x < start.x) return Directions.LEFT;
    if (end.x > start.x) return Directions.RIGHT;
    return null;
  }
};
