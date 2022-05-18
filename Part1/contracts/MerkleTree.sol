//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        //Initializing all the leaves
        for(uint i = 0; i < 8; i++) {
            hashes.push(0);
        }
        //Initializing other elements
        uint ele = 0;
        for(uint j = 8; j < 15; j++) {
            uint hash = PoseidonT3.poseidon([hashes[ele], hashes[ele+1]]);
            hashes.push(hash);
            ele +=2;
        }

        root = hashes[14];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;

        //Initializing other elements after updating the leaf hashes
        uint ele = 0;
        for(uint j = 8; j < 15; j++) {
            uint hash = PoseidonT3.poseidon([hashes[ele], hashes[ele+1]]);
            hashes[j] = hash;
            ele +=2;
        }

        index += 1;
        root = hashes[14];
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        bool verified = verifyProof(a,b,c,input);
        bool isMatching;
        if(input[0] == root){
            isMatching = true;
        }
        else {
            isMatching = false;
        }
        return (verified && isMatching);
    }
}
