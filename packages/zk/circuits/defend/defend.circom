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
    signal input characterTarget;
    signal input attackerLevel;

    // Output signal for the hash
    signal output hash;

    // Output signal for the battle result
    signal output battleResult;

    // Poseidon hash calculation
    component poseidonComponent = Poseidon(6);
    poseidonComponent.inputs[0] <== character1;
    poseidonComponent.inputs[1] <== character2;
    poseidonComponent.inputs[2] <== character3;
    poseidonComponent.inputs[3] <== character4;
    poseidonComponent.inputs[4] <== privateSalt;
    poseidonComponent.inputs[5] <== characterTarget;
    hash <== poseidonComponent.out;

    // Compare attackerLevel and characterTarget
    component compareLevel = LessThan(4); // Assuming levels are within 4 bits (0-15)
    compareLevel.in[0] <== characterTarget;
    compareLevel.in[1] <== attackerLevel;
    signal attackerWinsNormal <== compareLevel.out;

    // Special rule: attackerLevel == 1 and characterTarget == 4
    signal isAttackerLevelOne;
    signal isCharacterTargetFour;
    signal attackerWinsSpecial;

    // Check if attackerLevel == 1
    component isAttackerLevelOneEq = IsEqual();
    isAttackerLevelOneEq.in[0] <== attackerLevel;
    isAttackerLevelOneEq.in[1] <== 1;
    isAttackerLevelOne <== isAttackerLevelOneEq.out;

    // Check if characterTarget == 4
    component isCharacterTargetFourEq = IsEqual();
    isCharacterTargetFourEq.in[0] <== characterTarget;
    isCharacterTargetFourEq.in[1] <== 4;
    isCharacterTargetFour <== isCharacterTargetFourEq.out;

    // Logical AND: isAttackerLevelOne && isCharacterTargetFour
    signal andResult;
    andResult <== isAttackerLevelOne * isCharacterTargetFour;

    // Logical OR: attackerWinsNormal || attackerWinsSpecial
    // Calculate whether attackerWinsNormal is 1 or andResult is 1
    signal attackerWinsNormalNotZero;
    signal attackerWinsSpecialNotZero;

    attackerWinsNormalNotZero <== attackerWinsNormal;
    attackerWinsSpecialNotZero <== andResult;

    // Final battle result
    signal orResult;
    orResult <== attackerWinsNormalNotZero + attackerWinsSpecialNotZero;

    // Ensure battleResult is 1 if orResult is greater than 0
    signal resultNonZero;
    resultNonZero <== orResult - 1;
    signal isResultZero;
    isResultZero <== (resultNonZero * resultNonZero);

    battleResult <== 1 - isResultZero; // If orResult is greater than 0, battleResult should be 1, otherwise 0
}

component main {public [character1, character2, character3, character4, characterTarget, attackerLevel]} = CharacterBattleCheck();
