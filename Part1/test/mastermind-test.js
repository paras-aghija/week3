//[assignment] write your own unit test to show that your Mastermind variation circuit is working as expected

const chai = require("chai");
const path = require("path");
const { isTypedArray } = require("util/types");
const buildPoseidon = require("circomlibjs").buildPoseidon;
const wasm_tester = require("circom_tester").wasm;
const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("11");
const Fr = new F1Field(exports.p);

const assert = chai.assert;

describe("Mastermind tests ", async () => {
  it("SHould pass the test of Mastermind Challenge", async () => {
    try {
      const circuit = await wasm_tester(
        "contracts/circuits/MastermindVariation.circom"
      );
      await circuit.loadConstraints();

      const INPUT = {
        p1GuessA: "1",
        p1GuessB: "2",
        p1GuessC: "3",
        p1GuessD: "4",
        p1GuessE: "5",
        p2GuessA: "5",
        p2GuessB: "4",
        p2GuessC: "3",
        p2GuessD: "2",
        p2GuessE: "1",
        p1NumHit: "1",
        p1NumBlow: "2",
        p1SolnHash:
          "2146463365265127695383093589292212984136419211106577298730057477184926808077",
        p2NumHit: "3",
        p2NumBlow: "2",
        p2SolnHash:
          "21383000769172284782207289745058454323647441139709504633447713949075657675089",
        p1SolnA: "1",
        p1SolnB: "5",
        p1SolnC: "6",
        p1SolnD: "7",
        p1SolnE: "2",
        p2SolnA: "5",
        p2SolnB: "4",
        p2SolnC: "1",
        p2SolnD: "2",
        p2SolnE: "3",
        privSalt: "1234",
      };
      const poseidonHasher = await buildPoseidon();
      const hash = poseidonHasher([1234, 1, 5, 6, 7, 2]);
      const hash2 = poseidonHasher([1234, 5, 4, 1, 2, 3]);
      //   console.log(hash);
      //   let poseidonhash;
      //   for (let i = 0; i < hash.length; i++) {
      //   }
      let poseidonhash = poseidonHasher.F.toString(hash);
      let poseidonhash2 = poseidonHasher.F.toString(hash2);
      //   console.log(poseidonhash2);
      const witness = await circuit.calculateWitness(INPUT, true);
      console.log(witness[1]);
      console.log(poseidonhash);

      assert(Fr.eq(Fr.e(witness[2]), Fr.e(poseidonhash2)));
      assert(Fr.eq(Fr.e(witness[1], Fr.e(poseidonhash))));
    } catch (e) {
      console.log(e);
    }
  });
});
