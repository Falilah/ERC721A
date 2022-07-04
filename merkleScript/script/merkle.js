const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
const add1 = "0x0000000000000000000000000000000000000001";
const add2 = "0x0000000000000000000000000000000000000002";
const add3 = "0x0000000000000000000000000000000000000003";
const add4 = "0x0000000000000000000000000000000000000004";
let addresses = [add1, add2, add3, add4];

//hash leaves
let leaves = addresses.map((x) => keccak256(x));
//create a tree
let merkletree = new MerkleTree(leaves, keccak256, { sortPairs: true });
console.log(merkletree.toString());

//get roothasheh
let root = merkletree.getHexRoot().toString("hex");
console.log("root is :", root);

let address1 = leaves[0];

let whitelist1 = keccak256(address1);

let proof = merkletree.getHexProof(whitelist1);
console.log("the proof for whitelist 1 is:", proof);
