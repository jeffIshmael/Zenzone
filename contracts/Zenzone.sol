// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract zenzone{

uint totalProposals;
uint totalOffsetProps;
uint totalcompany;
uint totalOffsetters;
uint totalValidators;

//struct of the company thats needs carbon credits.
struct Buyer {
uint buyerId;
string compName;
uint regPin;
string category;
string description;
address buyerAdd;
string email;
uint phoneNo;
}

//array of buyers
Buyer[] public buyers;

//struct of the one rehabilitating envt.
struct Offsetter{
uint offsetterId;
string compName;
uint regPin;
string category;
string offSetCat;
string description;
address offsetterAdd;
string email;
uint phoneNo;
}

//array of offsetters
Offsetter[] public offsetters;

//struct for offset proposal
struct offsetProposal{
uint proposalId;
string category;
string description;
uint estAmount;
uint timestamp;
string IPFSHash;
address offsetterAdd;
bool approved;
}

//array of offset proposals
offsetProposal[] public offsetProposals;

//struct for bought credits
struct boughtCredit{
uint proposalId;
uint estAmount;
string IPFSHash;
uint timestamp;
address buyerAdd; 
}

//array of bought credits
boughtCredit[] public boughtCredits;

//struct of validator
struct validator{
uint validatorId;
string name;
address validatorAdd;
}

//array of validators
validator[] public validators;

struct Result {
    StructType structType;
    address addr;
    bytes data; // encoded struct data
    
}

enum StructType { None, Buyer, Offsetter, Validator }

// Function to receive Ether. msg.data must be empty
receive() external payable {}

// Fallback function is called when msg.data is not empty
fallback() external payable {}

//mappings of buyers
mapping (uint => Buyer) BuyernId;
mapping (string => Buyer) BuyernName;
mapping(address => Buyer) BuyernAddress;

//mappings of offsetters
mapping (uint => Offsetter) OffsetternId;
mapping (string => Offsetter) OffsetternName;
mapping(address => Offsetter) OffsetternAddress;

//mappings of proposals
mapping (address=> offsetProposal) offSetProposalAddress;
mapping (uint => offsetProposal) offSetProposalnId;

//mappings of bought credits
mapping (address => boughtCredit) boughtCreditsAddress;
mapping (uint => boughtCredit) boughtCreditsId;

//mapping of validators
mapping (uint => validator) validatornId;
mapping (string => validator) validatornName;
mapping(address => validator) validatornAddress;

// event emitted when offsetter is registered
event offsetterRegistered(uint offsetterId,
string compName,
uint regPin,
string category,
string offSetCat,
string description,
address offsetterAdd,
string email,
uint phoneNo);

//event of a registered user
event buyerRegistered(uint buyerId,
string compName,
uint regPin,
string category,
string description,
address buyerAdd,
string email,
uint phoneNo);

//event of an offset proposal
event offsetProposalCreated(uint proposalId,
string category,
string description,
uint estAmount,
uint timestamp,
string IPFSHash,
address offsetterAdd, bool approved);

//event of a bought credit
event boughtCreditCreated(uint proposalId,
uint estAmount,
string IPFSHash,
uint timestamp,
address buyerAdd);

//event to approve an offset proposal
event offsetProposalApproved(uint proposalId);

//event of registered validator
event validatorRegistered(uint validatorId, string name, address validatorAdd);

//function to register offsetter
function registerBuyer( string memory _compName,uint _regPin,string memory _category,string memory _description,string memory _email,uint _phoneNo) public {
require(!registeredOffsetter(msg.sender), "You are already registered as an offsetter");
require(!registeredBuyer(msg.sender), "You are already registered as a buyer");
uint _buyerId = totalcompany;
Buyer memory newBuyer = Buyer({
buyerId: _buyerId,
compName: _compName,
regPin: _regPin,
category: _category,
description: _description,
buyerAdd: msg.sender,
email: _email,
phoneNo: _phoneNo
});

BuyernId[_buyerId]= newBuyer;
BuyernAddress[msg.sender]= newBuyer;
BuyernName[_compName]= newBuyer;

buyers.push(newBuyer);
totalcompany++;

emit buyerRegistered(_buyerId, _compName, _regPin, _category, _description, msg.sender, _email, _phoneNo);
}


//function to register buyer
function registerOffsetter( string memory _compName,uint _regPin,string memory _category,string memory _offSetCat,string memory _description,string memory _email,uint _phoneNo)
public {
require(!registeredOffsetter(msg.sender), "You are already registered as an offsetter");
require(!registeredBuyer(msg.sender), "You are already registered as a buyer");
uint _offsetterId = totalOffsetters;
Offsetter memory newOffsetter = Offsetter({
offsetterId: _offsetterId,
compName: _compName,
regPin: _regPin,
category: _category,
offSetCat: _offSetCat,
description: _description,
offsetterAdd: msg.sender,
email: _email,
phoneNo: _phoneNo
});

OffsetternId[_offsetterId]= newOffsetter;
OffsetternAddress[msg.sender]= newOffsetter;
OffsetternName[_compName]= newOffsetter;

offsetters.push(newOffsetter);
totalOffsetters++;
emit offsetterRegistered(_offsetterId, _compName, _regPin, _category, _offSetCat, _description, msg.sender, _email, _phoneNo);
}

//fuction to make an offset proposal
function makeOffsetProposal( string memory _category,string memory _description,uint _estAmount) public {
require(registeredOffsetter(msg.sender), "Please register as an offsetter first");
uint _proposalId = totalOffsetProps;
offsetProposal memory newProposal = offsetProposal({
proposalId: _proposalId,
category: _category,
description: _description,
estAmount: _estAmount,
timestamp: block.timestamp,
IPFSHash: "",
offsetterAdd: msg.sender,
approved: false
});
offSetProposalnId[_proposalId]= newProposal;
offSetProposalAddress[msg.sender]= newProposal;
totalOffsetProps++;
emit offsetProposalCreated(_proposalId, _category, _description, _estAmount, block.timestamp, "", msg.sender, false);
}

//function to register validator
function registerValidator(string memory _name) public {
require(!registeredValidator(msg.sender), "You are already registered as a validator");
require(!registeredBuyer(msg.sender), "You are  registered as a buyer");
require(!registeredOffsetter(msg.sender), "You are  registered as an offsetter");
uint _validatorId = totalValidators;
validator memory newValidator = validator({
validatorId: _validatorId,
name: _name,
validatorAdd: msg.sender
});
validatornId[_validatorId]= newValidator;
validatornName[_name]= newValidator;
validatornAddress[msg.sender] = newValidator;
totalValidators++;
emit validatorRegistered(_validatorId, _name, msg.sender);
}

//function to get Carbon credits
function buyCarbonCredits(uint _estAmount) public payable {
    require(registeredBuyer(msg.sender), "Please register as a buyer first");
    (bool sent, ) = address(this).call{value: _estAmount}("");
    require(sent, "Insufficient funds");
    boughtCredit memory newCredit = boughtCredit({
    proposalId: totalProposals,
    estAmount: _estAmount,
    IPFSHash: "",
    timestamp: block.timestamp,
    buyerAdd: msg.sender
    });
    boughtCreditsId[totalProposals]= newCredit;
    boughtCreditsAddress[msg.sender]= newCredit;
    totalProposals++;
    emit boughtCreditCreated(totalProposals, _estAmount, " ",block.timestamp, msg.sender);
}

//function to get Carbon Credits from address
function getCarbonCredits( address _myadd) public view returns(boughtCredit memory){
    return boughtCreditsAddress[_myadd]; 
}

//function to get all offset Proposals
function getOffsetProposals() public view returns(offsetProposal[] memory){
    return offsetProposals;
}

//function to get all offset Proposals
function getOffsetProposal( uint _proposalId) public view returns(offsetProposal memory){
    return offSetProposalnId[_proposalId];
}

//function to get struct from address
function getStruct(address _myaddress) public view returns (Result memory) {
    for(uint i = 0; i < totalcompany; i++){
        if(buyers[i].buyerAdd == _myaddress){
            return Result(StructType.Buyer, buyers[i].buyerAdd, abi.encode(buyers[i]));
        }
    }
    for(uint j = 0; j < totalOffsetters; j++){
        if(OffsetternId[j].offsetterAdd == _myaddress){
            return Result(StructType.Offsetter, OffsetternId[j].offsetterAdd, abi.encode(OffsetternId[j]));
        }
    }
    for(uint k = 0; k < totalValidators; k++){
        if(validatornId[k].validatorAdd == _myaddress){
            return Result(StructType.Validator, validatornId[k].validatorAdd, abi.encode(validatornId[k]));
        }
    }
    return Result(StructType.None, address(0), "");
}

//function to get offsetter details from address
function getOffsetter(address _myaddress) public view returns(Offsetter memory){
    return OffsetternAddress[_myaddress];
}

//function to get buyer details from address
function getBuyer(address _myaddress) public view returns(Buyer memory){
    return BuyernAddress[_myaddress];
}

//function to get validator details from address
function getValidator(address _myaddress) public view returns (validator memory){
    return validatornAddress[_myaddress];
}

//function to approve an offset proposal
function approveOffsetProposal( uint _proposalId) public payable {
    require(registeredValidator(msg.sender), "Only validators can approve");
    require(offSetProposalnId[_proposalId].approved == false, "this proposal isalready approved ");
    offSetProposalnId[_proposalId].approved = true;
     // Retrieve the receiver address and the amount to be sent
    address payable receiver = payable(offSetProposalnId[_proposalId].offsetterAdd);
    uint estAmount = offSetProposalnId[_proposalId].estAmount;
    // Check if the contract has enough Ether to send
    require(address(this).balance >= estAmount, "Insufficient funds in contract");
    // Send Ether to the receiver
    (bool sentToReceiver, ) = receiver.call{value: estAmount}("");
    require(sentToReceiver, "Failed to send Ether to receiver");
    // Emit the approval event
    emit offsetProposalApproved(_proposalId);
    }


//function to check if an address is registered
function registeredBuyer( address _myadd) public view returns(bool){
for (uint i=0; i < totalcompany; i++ ){
if( BuyernId[i].buyerAdd == _myadd ){
return true;
}
}
return false;}

//function to check if an address is registered
function registeredOffsetter( address _myadd) public view returns(bool){
for (uint i=0; i < totalOffsetters; i++ ){
if( OffsetternId[i].offsetterAdd == _myadd){
return true;
}
}
return false;
}

//function to check if an address is registered validator
function registeredValidator( address _myadd) public view returns(bool){
for (uint i=0; i < totalValidators; i++ ){
if( validatornId[i].validatorAdd == _myadd){
return true;
}
}
return false;}

//function to view contract balance
function checkContractBal() public view returns(uint){
    return address(this).balance;
}

}
