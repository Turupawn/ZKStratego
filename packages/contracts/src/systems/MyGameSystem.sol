// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { Character, CharacterData } from "../codegen/index.sol";
import { PlayerPrivateState } from "../codegen/index.sol";
import { Direction } from "../codegen/common.sol";
import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";

import { EncodedLengths, EncodedLengthsLib } from "@latticexyz/store/src/EncodedLengths.sol";

interface ICircomAttackVerifier {
    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[4] calldata _pubSignals) external view returns (bool);
}

interface ICircomDefendVerifier {
    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[4] calldata _pubSignals) external view returns (bool);
}

contract MyGameSystem is System {
  function spawn(int32 x, int32 y, uint32 commitment) public {
    //require(PlayerPrivateState.getCommitment(_msgSender()) == 0, "Player already spawned");

    Character.set(x, y, _msgSender(), 0, false);
    Character.set(x, y + 1, _msgSender(), 0, false);
    Character.set(x, y + 2, _msgSender(), 0, false);
    Character.set(x, y + 3, _msgSender(), 0, false);

    PlayerPrivateState.set(_msgSender(), commitment);
  }

  function move(int32 characterAtX, int32 characterAtY, Direction direction) public {
    CharacterData memory character = Character.get(characterAtX, characterAtY);

    //require(!character.isDead, "Character is dead");
    require(character.attackedAt == 0, "Character is under attack");
    require(character.owner == _msgSender(), "Only owner");

    int32 x = characterAtX;
    int32 y = characterAtY;

    if(direction == Direction.Up)
      y -= 1;
    if(direction == Direction.Down)
      y += 1;
    if(direction == Direction.Left)
      x -= 1;
    if(direction == Direction.Right)
      x += 1;
    
    CharacterData memory characterAtDestination = Character.get(x, y);
    require(characterAtDestination.owner == address(0), "Destination is occupied");

    Character.deleteRecord(characterAtX, characterAtY);
    Character.set(x, y, _msgSender(), 0, false);
  }

  function attack(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[4] calldata _pubSignals,
    int32 fromX, int32 fromY, int32 toX, int32 toY
  ) public {
    // TODO: verifyProof
    require(Character.getOwner(fromX, fromY) == _msgSender(), "You're not the planet owner");
    Character.setAttackedAt(toX, toY, uint32(block.timestamp));
  }

  function defend(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[4] calldata _pubSignals,
    int32 fromX, int32 fromY
  ) public {
    
  }

  function killUnresponsiveCharacter(int32 x, int32 y) public {
    uint32 attackedAt = Character.getAttackedAt(x, y);
    uint32 MAX_WAIT_TIME = 5 minutes;
    require(attackedAt>0 && (attackedAt - uint32(block.timestamp)) >  MAX_WAIT_TIME, "Can kill character now");
    Character.setIsDead(x, y, true);
  }

  function getOwner(int32 x, int32 y) public view returns(address) {
    return Character.getOwner(x, y);
  }
}
