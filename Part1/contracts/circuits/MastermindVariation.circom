pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";

// [assignment] implement a variation of mastermind from https://en.wikipedia.org/wiki/Mastermind_(board_game)#mastermin_challenge as a circuit
// Mastermind Challenge (2 player)
template MastermindVariation() {

    // public inputs
    signal input p1GuessA;
    signal input p1GuessB;
    signal input p1GuessC;
    signal input p1GuessD;
    signal input p1GuessE;

    signal input p2GuessA;
    signal input p2GuessB;
    signal input p2GuessC;
    signal input p2GuessD;
    signal input p2GuessE;

    signal input p1NumHit;
    signal input p1NumBlow;
    signal input p1SolnHash;

    signal input p2NumHit;
    signal input p2NumBlow;
    signal input p2SolnHash;

    // private inputs
    signal input p1SolnA;
    signal input p1SolnB;
    signal input p1SolnC;
    signal input p1SolnD;
    signal input p1SolnE;

    signal input p2SolnA;
    signal input p2SolnB;
    signal input p2SolnC;
    signal input p2SolnD;
    signal input p2SolnE;

    signal input privSalt;

    // Output
    signal output p1Result;
    signal output p2Result;

    var p1Guess[5] = [p1GuessA, p1GuessB, p1GuessC, p1GuessD, p1GuessE];
    var p1Soln[5] = [p1SolnA, p1SolnB, p1SolnC, p1SolnD, p1SolnE];

    var p2Guess[5] = [p2GuessA, p2GuessB, p2GuessC, p2GuessD, p2GuessE];
    var p2Soln[5] = [p2SolnA, p2SolnB, p2SolnC, p2SolnD, p2SolnE];

    var j = 0;
    var k = 0;
    component lessThan[20];
    component p1equalGuess[16];
    component p1equalSoln[16];
    component p2equalGuess[16];
    component p2equalSoln[16];
    var equalIdx = 0;

    for(j=0;j<5;j++){
        lessThan[j] = LessThan(4);
        lessThan[j].in[0] <== p1Guess[j];
        lessThan[j].in[1] <== 8;
        lessThan[j].out === 1;

        lessThan[j+5] = LessThan(4);
        lessThan[j+5].in[0] <== p2Guess[j];
        lessThan[j+5].in[1] <== 8;
        lessThan[j+5].out === 1;
        
        lessThan[j+10] = LessThan(4);
        lessThan[j+10].in[0] <== p1Soln[j];
        lessThan[j+10].in[1] <== 8;
        lessThan[j+10].out === 1;

        lessThan[j+15] = LessThan(4);
        lessThan[j+15].in[0] <== p2Soln[j];
        lessThan[j+15].in[1] <== 8;
        lessThan[j+15].out === 1;

        for(k=j+1;k<5;k++){
            p1equalGuess[equalIdx] = IsEqual();
            p1equalGuess[equalIdx].in[0] <== p1Guess[j];
            p1equalGuess[equalIdx].in[1] <== p1Guess[k];
            p1equalGuess[equalIdx].out === 0;

            p1equalSoln[equalIdx] = IsEqual();
            p1equalSoln[equalIdx].in[0] <== p1Soln[j];
            p1equalSoln[equalIdx].in[1] <== p1Soln[k];
            p1equalSoln[equalIdx].out === 0;

            p2equalGuess[equalIdx] = IsEqual();
            p2equalGuess[equalIdx].in[0] <== p2Guess[j];
            p2equalGuess[equalIdx].in[1] <== p2Guess[k];
            p2equalGuess[equalIdx].out === 0;

            p2equalSoln[equalIdx] = IsEqual();
            p2equalSoln[equalIdx].in[0] <== p2Soln[j];
            p2equalSoln[equalIdx].in[1] <== p2Soln[k];
            p2equalSoln[equalIdx].out === 0;

            equalIdx++;
        }
    }

    // Count hit & blow
    var p1hit = 0;
    var p1blow = 0;
    component p1equalHB[25];

    for (j=0; j<5; j++) {
        for (k=0; k<5; k++) {
            p1equalHB[5*j+k] = IsEqual();
            p1equalHB[5*j+k].in[0] <== p1Soln[j];
            p1equalHB[5*j+k].in[1] <== p1Guess[k];
            p1blow += p1equalHB[5*j+k].out;
            if (j == k) {
                p1hit += p1equalHB[5*j+k].out;
                p1blow -= p1equalHB[5*j+k].out;
            }
        }
    }

    var p2hit = 0;
    var p2blow = 0;
    component p2equalHB[25];

    for (j=0; j<5; j++) {
        for (k=0; k<5; k++) {
            p2equalHB[5*j+k] = IsEqual();
            p2equalHB[5*j+k].in[0] <== p2Soln[j];
            p2equalHB[5*j+k].in[1] <== p2Guess[k];
            p2blow += p2equalHB[5*j+k].out;
            if (j == k) {
                p2hit += p2equalHB[5*j+k].out;
                p2blow -= p2equalHB[5*j+k].out;
            }
        }
    }

    component p1EqualHit = IsEqual();
    p1EqualHit.in[0] <== p1NumHit;
    p1EqualHit.in[1] <== p1hit;
    p1EqualHit.out === 1;

    component p2EqualHit = IsEqual();
    p2EqualHit.in[0] <== p2NumHit;
    p2EqualHit.in[1] <== p2hit;
    p2EqualHit.out === 1;

    component p1EqualBlow = IsEqual();
    p1EqualBlow.in[0] <== p1NumBlow;
    p1EqualBlow.in[1] <== p1blow;
    p1EqualBlow.out === 1;

    component p2EqualBlow = IsEqual();
    p2EqualBlow.in[0] <== p2NumBlow;
    p2EqualBlow.in[1] <== p2blow;
    p2EqualBlow.out === 1;

    component poseidon1 = Poseidon(6);
    poseidon1.inputs[0] <== privSalt;
    poseidon1.inputs[1] <== p1SolnA;
    poseidon1.inputs[2] <== p1SolnB;
    poseidon1.inputs[3] <== p1SolnC;
    poseidon1.inputs[4] <== p1SolnD;
    poseidon1.inputs[5] <== p1SolnE;

    p1Result <== poseidon1.out;
    // log(p1Result);
    p1SolnHash === p1Result;

    component poseidon2 = Poseidon(6);
    poseidon2.inputs[0] <== privSalt;
    poseidon2.inputs[1] <== p2SolnA;
    poseidon2.inputs[2] <== p2SolnB;
    poseidon2.inputs[3] <== p2SolnC;
    poseidon2.inputs[4] <== p2SolnD;
    poseidon2.inputs[5] <== p2SolnE;

    p2Result <== poseidon2.out;
    // log(p2Result);
    p2SolnHash === p2Result;
}

component main {public [p1GuessA, p1GuessB, p1GuessC, p1GuessD, p1GuessE, p2GuessA, p2GuessB, p2GuessC, p2GuessD, p2GuessE, p1NumHit, p1NumBlow, p1SolnHash, p2NumHit, p2NumBlow, p2SolnHash]} = MastermindVariation();



/* INPUT = {
    "p1GuessA" : "1",
    "p1GuessB" : "2",
    "p1GuessC" : "3",
    "p1GuessD" : "4",
    "p1GuessE" : "5",
    "p2GuessA" : "5",
    "p2GuessB" : "4",
    "p2GuessC" : "3",
    "p2GuessD" : "2",
    "p2GuessE" : "1",
    "p1NumHit" : "1",
    "p1NumBlow" : "2",
    "p1SolnHash" : "2146463365265127695383093589292212984136419211106577298730057477184926808077",
    "p2NumHit" : "3",
    "p2NumBlow" : "2",
    "p2SolnHash" : "21383000769172284782207289745058454323647441139709504633447713949075657675089",
    "p1SolnA" : "1",
    "p1SolnB" : "5",
    "p1SolnC" : "6",
    "p1SolnD" : "7",
    "p1SolnE" : "2",
    "p2SolnA" : "5",
    "p2SolnB" : "4",
    "p2SolnC" : "1",
    "p2SolnD" : "2",
    "p2SolnE" : "3",
    "privSalt" : "1234"
} */