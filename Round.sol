// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Node.sol";

abstract contract Round is Node{
    uint public roundCount;

    address public exchange;
    modifier onlyExchange{
        require(msg.sender == exchange, "Only the exchange can access.");
        _;
    }

    address[] userAddressArr;
    struct userInfo {
        bool isUser;
        bool ack;
    }
    mapping (address => userInfo) public userMap;
    modifier onlyUser{
        require(userMap[msg.sender].isUser == true);
        _;
    }

    event posted(address, bytes32);

    struct snapshot {
        uint[] userSnapshot;
        uint[] exchangeSnapshot;
    }
    mapping (address => snapshot) internal manageSnap;
    event userSnapPublished(uint, address);
    event exchangeSnapPublished(uint, address);

    uint8 public roundVotes;
    mapping (address => bool) public roundVoted;
    event votedRound(string);
    event nextRoundBegins(string);

    uint public calcReservesUser;
    uint public calcReservesExch;
    uint public actReserves;



    constructor (){
        exchange = msg.sender;
    }

    // Checks if the input address is the address of a registered user.
    function isUserEnrolled (address _address) external view returns (bool){
        return userMap[_address].isUser;
    }

    // Registers a user.
    function addUser(address userAddress) onlyExchange external {
        userMap[userAddress].isUser = true;
    }

    // User posts the encrypted seed value.
    function post(bytes32 _encSeed) onlyUser external {
        emit posted(msg.sender, _encSeed);
    }

    // Exchange posts acknowledgement that the user-posted key and user-sent key is identical.
    function postAck(address user) onlyExchange external {
        userMap[user].ack = true;
    }

    // User publishes a snapshot.
    function publishUserSnapshot(uint[] memory snap) onlyUser external {
        manageSnap[msg.sender].userSnapshot = snap;
        emit userSnapPublished(roundCount, msg.sender);
    }

    // Exchange publishes a user's snapshot.
    function publishExchangeSnapshot(address _user, uint[] memory _snap) onlyExchange external {
        manageSnap[_user].exchangeSnapshot = _snap;
        emit exchangeSnapPublished(roundCount, _user);
    }

    // Checks if a user's exchange-published-snapshot and user-published-snapshot matches.
    function individualAudit(address _user) external view returns (bool){
        if (keccak256(abi.encodePacked(manageSnap[_user].exchangeSnapshot)) == keccak256(abi.encodePacked(manageSnap[_user].userSnapshot))){
            return true;
        }
        else {
            return false;
        }
    }

    // Node publishes user-snapshot-based calculated reserves
    function calculatedReservesUser(uint reserves) onlyNode external{
        calcReservesUser = reserves;
    }

    // Node publishes exchange-snapshot-based calculated reserves
    function calculatedReservesExchange(uint reserves) onlyNode external{
        calcReservesExch = reserves;
    }

    // Node publishes actual reserves
    function actualReserves(uint reserves) onlyNode external{
        actReserves = reserves;
    }


    // Nodes vote to start the next round.
    function voteNextRound() onlyNode external {
        require (!roundVoted[msg.sender]);
        roundVotes++;
        emit votedRound("Voted");
        
        try this.nextRound() {
            emit nextRoundBegins("Next Round Begins");
        } catch {}
    }

    // Only callable by this contract, begins the next round.
    function nextRound() external {
        require (msg.sender == address(this));
        require (roundVotes >= threshold);
        
        for (uint256 i=0; i < userAddressArr.length; i++){
            delete userMap[userAddressArr[i]].ack;
        }
        delete calcReservesUser;
        delete calcReservesExch;
        delete actReserves;
        roundCount++;
    }
}
