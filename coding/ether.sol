pragma solidity >= 0.5.0;

contract newRinkeby {

    struct User {
        address addr;
        uint donate;
        uint donateAt;
        uint withdrawal;
        uint withdrawalAt;
        bool blacklist;
    }

    User [] UsersIndex;
    address owner;
    uint withdrawalAmount = 0.5 ether ;

    mapping(address => User) users;

    event UserDonate( address indexed Donor, uint amount);
    event UserWithdrawal(address indexed withdrawer, uint amount);


    constructor(){
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    modifier newUser {
        if(users[msg.sender].addr == address(0x0)){
            users[msg.sender] = User(msg.sender, 0,0,0,0,false);
        }
        _;
    }

    // owner's functions

    function addBlacklist(address _blacklist) external onlyOwner {
        users[_blacklist].blacklist = true;
    }

    function removeBlacklist(address _blacklist) external onlyOwner {
        users[_blacklist].blacklist = false;
    }

    function setWithdrawalAmount(uint _amount) external onlyOwner {
        require(_amount > 0);
        withdrawalAmount = _amount;
    }

    function remove() external payable onlyOwner{
        selfdestruct(payable(owner));
    }

    //Donor


    function donate(uint _amount) external payable newUser{
        require(msg.value == _amount);
        users[msg.sender].donate += _amount;
        users[msg.sender].donateAt = block.timestamp;
        if(users[msg.sender].donate >= 10 ether && users[msg.sender].blacklist) users[msg.sender].blacklist = false;
        emit UserDonate(msg.sender, msg.value);
    }

    //withdrawal

    function withdrawal() external payable newUser{
        require(users[msg.sender].withdrawalAt <= block.timestamp - 1 days, "Please wait for 24 hours");
        payable(msg.sender).transfer(withdrawalAmount);
        users[msg.sender].withdrawalAt = block.timestamp;
        users[msg.sender].withdrawal += withdrawalAmount;
        emit UserWithdrawal(msg.sender, withdrawalAmount);

    }

    function getBalance() external view returns(uint){
        return address(this).balance;
    }


    
}