pragma solidity >=0.4.22 <0.9.0;

// SPDX-License-Identifier: MIT

contract PPHToken {
    string public name = "PPH Token";
    string public symbol = "PPH";
    string public standard = "PPH Token v1.0";
    uint256 public totalSupply;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 _initialSupply) {
        balanceOf[msg.sender] = _initialSupply;
        //allocate the initial supply
        totalSupply = _initialSupply;
    }

    //Transfer

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        //Exception
        require(balanceOf[msg.sender] >= _value);
        //Transfer the balance
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        //Transfer Event
        emit Transfer(msg.sender, _to, _value);

        //Return a bool
        return true;
    }

    // Delegate transfer: 1 function allows account to approve a transfer, other will handle delegate transfer; seal a transfer without sender
    //approve
    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        //approve event
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    //transfer from
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        //from account has the value
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}