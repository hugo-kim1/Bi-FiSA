// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Node{
    address[] public nodeList;
    uint8 public threshold;

    struct NodeCheck {
        bool isNode;
        bool posted;
        bool votedReset;
    }
    mapping (address => NodeCheck) public nodeInfo;

    mapping (address => uint8) public voteNewNode;
    mapping (address => uint8) public voteBanNode;

    // A modifier that checks if the caller of the function is one of the registered nodes.
    modifier onlyNode{
        require(nodeInfo[msg.sender].isNode, "Not registered as a node.");
        _;
    }

    constructor (address[] memory nodes){
        nodeList = nodes;

        for (uint8 i =0; i < nodeList.length; i++) {
            nodeInfo[nodeList[i]].isNode = true;
        }
    }

    // Adds new node(s) by votes.
    function newNode (address candidate) onlyNode external{
        require(!nodeInfo[candidate].isNode);
        voteNewNode[candidate]++;

        if (voteNewNode[candidate] >= threshold){
            nodeInfo[candidate].isNode = true;
            nodeList.push(candidate);
            threshold = (uint8(nodeList.length)+1)/3;
        }
    }

    // Bans new node(s) by votes.
    function banNode (address candidate) onlyNode external{
        require(nodeInfo[candidate].isNode);
        require(nodeList.length > 2);
        voteBanNode[candidate]++;

        if (voteBanNode[candidate] >= threshold){
            nodeInfo[candidate].isNode = false;
            for (uint8 i; i < uint8(nodeList.length); i++) {
                if (nodeList[i] == candidate) {
                    nodeList[i] = nodeList[uint8(nodeList.length) - 1];
                    nodeList.pop();
                    break;
                }
            }
            threshold = (uint8(nodeList.length)+1)/2;
        }
    }
}