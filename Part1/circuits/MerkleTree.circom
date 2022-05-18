pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    var treeElements = 0;
    var treeHashesNum = 0;
    var te = 0;
    for(var i = n; i > 0; i--) {
        treeElements += 2**(i-1);
    }

    for(var i = n; i > 0; i--) {
        treeHashesNum += 2**(i);
    }

    component pos[treeElements];
   
    var treeHashes[treeHashesNum];
    
    for(var i = 0; i < (2**n); i++){
        treeHashes[i] = leaves[i];
    }

    var ele = 0;
    var j = 0;
    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    for(var i = n; i > 0; i--) {
        for(j = ele; (j+2) < (ele + (2**i)); j=j+2) {
            var num = 0;
            pos[te] = Poseidon(2);
            pos[te].inputs[0] <== treeHashes[j];
            pos[te].inputs[1] <== treeHashes[j+1];

            pos[te].out ==> treeHashes[ele + (2**i)+(num)];
           
            te += 1;
            num += 1;
        }
        ele = j;
    }

    root <== treeHashes[treeHashesNum];

}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component hashNum[n];
    component switchers[n];
    var prev;
    var te = 0;
    prev = leaf;

    for(var i=0; i < n; i++) {
        hashNum[te] = Poseidon(2);

        switchers[te] = Switcher();
        switchers[te].sel <== path_index[i];
        switchers[te].L <== prev;
        switchers[te].R <== path_elements[i];

        hashNum[te].inputs[0] <== switchers[te].L;
        hashNum[te].inputs[1] <== switchers[te].R;

        prev = hashNum[te].out;
        te += 1;
    }

    root <== prev;
}