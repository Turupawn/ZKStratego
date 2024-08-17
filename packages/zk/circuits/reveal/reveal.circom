pragma circom 2.0.0;

include "../circomlib/circuits/poseidon.circom";
include "../circomlib/circuits/comparators.circom";

template spawn() {
    // Input signals
    signal input character1;
    signal input character2;
    signal input character3;
    signal input character4;
    signal input privateSalt;
    signal input characterReveal; // The character index to reveal (1, 2, 3, or 4)
    signal input valueReveal; // The value that is claimed to be assigned to the character

    // Output signal for the hash
    signal output hash;

    // Poseidon hash calculation
    component poseidonComponent = Poseidon(5);
    poseidonComponent.inputs[0] <== character1;
    poseidonComponent.inputs[1] <== character2;
    poseidonComponent.inputs[2] <== character3;
    poseidonComponent.inputs[3] <== character4;
    poseidonComponent.inputs[4] <== privateSalt;
    hash <== poseidonComponent.out;

    // Comparator components for character reveal verification
    component isChar1 = IsEqual();
    component isChar2 = IsEqual();
    component isChar3 = IsEqual();
    component isChar4 = IsEqual();
    isChar1.in[0] <== characterReveal;
    isChar1.in[1] <== 1;
    isChar2.in[0] <== characterReveal;
    isChar2.in[1] <== 2;
    isChar3.in[0] <== characterReveal;
    isChar3.in[1] <== 3;
    isChar4.in[0] <== characterReveal;
    isChar4.in[1] <== 4;

    // Value check depending on the revealed character
    component checkChar1 = IsEqual();
    component checkChar2 = IsEqual();
    component checkChar3 = IsEqual();
    component checkChar4 = IsEqual();

    checkChar1.in[0] <== isChar1.out * character1 + (1 - isChar1.out) * 0;
    checkChar1.in[1] <== valueReveal;

    checkChar2.in[0] <== isChar2.out * character2 + (1 - isChar2.out) * 0;
    checkChar2.in[1] <== valueReveal;

    checkChar3.in[0] <== isChar3.out * character3 + (1 - isChar3.out) * 0;
    checkChar3.in[1] <== valueReveal;

    checkChar4.in[0] <== isChar4.out * character4 + (1 - isChar4.out) * 0;
    checkChar4.in[1] <== valueReveal;

    signal validReveal1;
    signal validReveal2;
    signal validReveal3;
    signal validReveal4;

    validReveal1 <== checkChar1.out;
    validReveal2 <== checkChar2.out;
    validReveal3 <== checkChar3.out;
    validReveal4 <== checkChar4.out;

    signal validReveal <== validReveal1 + validReveal2 + validReveal3 + validReveal4;
    validReveal === 1;

    // Comparators to check for presence of values 1, 2, 3, 4
    component isOne1 = IsEqual();
    component isOne2 = IsEqual();
    component isOne3 = IsEqual();
    component isOne4 = IsEqual();
    isOne1.in[0] <== character1;
    isOne1.in[1] <== 1;
    isOne2.in[0] <== character2;
    isOne2.in[1] <== 1;
    isOne3.in[0] <== character3;
    isOne3.in[1] <== 1;
    isOne4.in[0] <== character4;
    isOne4.in[1] <== 1;
    signal oneExists <== isOne1.out + isOne2.out + isOne3.out + isOne4.out;
    oneExists === 1;

    component isTwo1 = IsEqual();
    component isTwo2 = IsEqual();
    component isTwo3 = IsEqual();
    component isTwo4 = IsEqual();
    isTwo1.in[0] <== character1;
    isTwo1.in[1] <== 2;
    isTwo2.in[0] <== character2;
    isTwo2.in[1] <== 2;
    isTwo3.in[0] <== character3;
    isTwo3.in[1] <== 2;
    isTwo4.in[0] <== character4;
    isTwo4.in[1] <== 2;
    signal twoExists <== isTwo1.out + isTwo2.out + isTwo3.out + isTwo4.out;
    twoExists === 1;

    component isThree1 = IsEqual();
    component isThree2 = IsEqual();
    component isThree3 = IsEqual();
    component isThree4 = IsEqual();
    isThree1.in[0] <== character1;
    isThree1.in[1] <== 3;
    isThree2.in[0] <== character2;
    isThree2.in[1] <== 3;
    isThree3.in[0] <== character3;
    isThree3.in[1] <== 3;
    isThree4.in[0] <== character4;
    isThree4.in[1] <== 3;
    signal threeExists <== isThree1.out + isThree2.out + isThree3.out + isThree4.out;
    threeExists === 1;

    component isFour1 = IsEqual();
    component isFour2 = IsEqual();
    component isFour3 = IsEqual();
    component isFour4 = IsEqual();
    isFour1.in[0] <== character1;
    isFour1.in[1] <== 4;
    isFour2.in[0] <== character2;
    isFour2.in[1] <== 4;
    isFour3.in[0] <== character3;
    isFour3.in[1] <== 4;
    isFour4.in[0] <== character4;
    isFour4.in[1] <== 4;
    signal fourExists <== isFour1.out + isFour2.out + isFour3.out + isFour4.out;
    fourExists === 1;
}

component main {public [characterReveal, valueReveal]} = spawn();
