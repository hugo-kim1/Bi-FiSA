// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Node.sol";
import "./Round.sol";

contract Key is Node, Round{
    mapping (bytes32 => uint8) internal keyCount;
    bytes32[] internal possibleKeys;
    bytes32 internal key;
    bool internal isKeySet;
    uint8 internal voteResetCount;

    event keySet();
    event fatalKeyError();
    event resetVoted();
    event keyReset();

    // Sets the list of initially registered nodes.
    constructor(address[] memory nodes) Node(nodes) {
        threshold = (uint8(nodes.length)+1)/3;
    }

    // Returns the list of registed nodes.
    function browseNodes() public view returns (address[] memory) {
        return nodeList;
    }

    // Checks if all the nodes have posted their public keys.
    function allPosted() public view returns (bool) {
        for (uint8 i = 0; i < uint8(nodeList.length); i++){
            if (!nodeInfo[nodeList[i]].posted){
                return false;
            }
        }
        return true;
    }

    // A function that can only be called by the node.
    // Node posts a public key.
    function keyPost(bytes32 _key) onlyNode external {
        require(!nodeInfo[msg.sender].posted, "Already posted a key.");

        if (keyCount[_key] == 0){
            possibleKeys.push(_key);
            keyCount[_key]++;
        } else {
            keyCount[_key]++;
        }

        nodeInfo[msg.sender].posted = true;
    }

    // Establish the public key, by checking if there exists a key that is posted by more than the theshold number of nodes.
    function setKey() external {
        require (allPosted() && !isKeySet);

        for (uint8 i = 0; i < uint8(possibleKeys.length); i++) {
            if (keyCount[possibleKeys[i]] >= threshold){
                key = possibleKeys[i];
                isKeySet = true;
                emit keySet();
                // send erc20 tokens to msg.sender as a reward
                break;
            }
            else{
                this.resetKey();
            }
        }
        emit fatalKeyError();
    }

    // A function that can only be called by the node.
    // Nodes vote to reset the public key.
    function voteReset() onlyNode external {
        require(!nodeInfo[msg.sender].votedReset);
        voteResetCount++;
        nodeInfo[msg.sender].votedReset = true;
        emit resetVoted();

        if (voteResetCount >= threshold){
            this.resetKey();
        }
    }

    // A function that can only be called by this contract.
    // Resets the public key.
    function resetKey() external {
        require(msg.sender == address(this));

        delete key;
        for (uint8 i =0; i < uint8(nodeList.length); i++) {
            delete nodeInfo[nodeList[i]].posted;
        }
        delete isKeySet;
        delete possibleKeys;

        delete voteResetCount;
    }
}
