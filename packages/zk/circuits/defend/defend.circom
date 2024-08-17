pragma circom 2.0.0;

include "../circomlib/circuits/poseidon.circom";
include "../circomlib/circuits/comparators.circom";

template CharacterBattleCheck() {
    // Input signals
    signal input character1;
    signal input character2;
    signal input character3;
    signal input character4;
    signal input privateSalt;
    signal input characterTarget; // 1-based index: 1 for character1, 2 for character2, etc.
    signal input attackerLevel;

    // Output signal for the hash
    signal output hash;

    // Output signal for the battle result
    signal output battleResult;

    // Poseidon hash calculation
    component poseidonComponent = Poseidon(5);
    poseidonComponent.inputs[0] <== character1;
    poseidonComponent.inputs[1] <== character2;
    poseidonComponent.inputs[2] <== character3;
    poseidonComponent.inputs[3] <== character4;
    poseidonComponent.inputs[4] <== privateSalt;
    hash <== poseidonComponent.out;

    // Create binary indicators for each target
    signal isTarget1;
    signal isTarget2;
    signal isTarget3;
    signal isTarget4;

    // Check if characterTarget matches 1, 2, 3, or 4
    component isTarget1Eq = IsEqual();
    isTarget1Eq.in[0] <== characterTarget;
    isTarget1Eq.in[1] <== 1;
    isTarget1 <== isTarget1Eq.out;

    component isTarget2Eq = IsEqual();
    isTarget2Eq.in[0] <== characterTarget;
    isTarget2Eq.in[1] <== 2;
    isTarget2 <== isTarget2Eq.out;

    component isTarget3Eq = IsEqual();
    isTarget3Eq.in[0] <== characterTarget;
    isTarget3Eq.in[1] <== 3;
    isTarget3 <== isTarget3Eq.out;

    component isTarget4Eq = IsEqual();
    isTarget4Eq.in[0] <== characterTarget;
    isTarget4Eq.in[1] <== 4;
    isTarget4 <== isTarget4Eq.out;

    // Ensure exactly one of the targets is selected
    signal sumTargets;
    sumTargets <== isTarget1 + isTarget2 + isTarget3 + isTarget4;
    sumTargets === 1;

    // Use separate variables to hold the selected character values
    signal selectedCharacter1;
    signal selectedCharacter2;
    signal selectedCharacter3;
    signal selectedCharacter4;

    // Enforce that only one of the selectedCharacter variables holds the value
    selectedCharacter1 <== isTarget1 * character1;
    selectedCharacter2 <== isTarget2 * character2;
    selectedCharacter3 <== isTarget3 * character3;
    selectedCharacter4 <== isTarget4 * character4;

    // Aggregate the selected character value
    signal selectedCharacter;
    selectedCharacter <== selectedCharacter1 + selectedCharacter2 + selectedCharacter3 + selectedCharacter4;

    // Compare attackerLevel and selectedCharacter
    component compareLevel = LessThan(4); // Assuming levels are within 4 bits (0-15)
    compareLevel.in[0] <== selectedCharacter;
    compareLevel.in[1] <== attackerLevel;
    signal attackerWinsNormal <== compareLevel.out;

    // Special rule: attackerLevel == 1 and selectedCharacter == 4
    component isAttackerLevelOneEq = IsEqual();
    isAttackerLevelOneEq.in[0] <== attackerLevel;
    isAttackerLevelOneEq.in[1] <== 1;
    signal isAttackerLevelOne <== isAttackerLevelOneEq.out;

    component isCharacterTargetFourEq = IsEqual();
    isCharacterTargetFourEq.in[0] <== selectedCharacter;
    isCharacterTargetFourEq.in[1] <== 4;
    signal isCharacterTargetFour <== isCharacterTargetFourEq.out;

    signal attackerWinsSpecial;
    attackerWinsSpecial <== isAttackerLevelOne * isCharacterTargetFour;

    // Determine if the attacker wins either normally or via special rule
    signal attackerWins;
    attackerWins <== attackerWinsNormal + attackerWinsSpecial;

    // Convert attackerWins to a binary value (0 or 1)
    signal isAttackerWins;
    signal zeroFlag;
    signal oneFlag;

    // Determine zeroFlag: 1 if attackerWins == 0, else 0
    zeroFlag <== attackerWins * (attackerWins - 1);
    oneFlag <== 1 - zeroFlag;

    // isAttackerWins should be 1 if attackerWins > 0, else 0
    isAttackerWins <== attackerWins - zeroFlag;

    // Calculate the battleResult: 1 if defender wins, 2 if attacker wins
    signal defenderWins;
    defenderWins <== 1 - isAttackerWins;

    // Output battleResult: 1 if defender wins, 2 if attacker wins
    battleResult <== 1 + isAttackerWins;

    log(battleResult);
}

component main {public [characterTarget, attackerLevel]} = CharacterBattleCheck();
