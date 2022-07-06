const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
let add1 = "0x0000000000000000000000000000000000000001";
let add2 = "0x0000000000000000000000000000000000000002";
let add3 = "0x0000000000000000000000000000000000000003";
let add4 = "0x0000000000000000000000000000000000000004";

let addresses = [add1, add2, add3, add4];

//hash leaves
let leaves = addresses.map((x) => keccak256(x));
//create a tree
let merkletree = new MerkleTree(leaves, keccak256, {
  sortPairs: true,
  sortLeaves: true,
});
console.log(merkletree.toString());

//get roothasheh
let root = merkletree.getHexRoot().toString("hex");
console.log("root is :", root);

let address1 = leaves[0];
// console.log(address1.toString("hex"));

// let whitelist1 = keccak256(address1);
// console.log(whitelist1.toString("hex"));

//get proof of the first element
let proof = merkletree.getHexProof(leaves[0]);
console.log("the proof for whitelist 1 is:", proof);
let proofHashed = keccak256(proof).toString("hex");
console.log("proof hashed", proofHashed);
//verify an address
let verify = merkletree.verify(proof, address1, root);
console.log(verify);
