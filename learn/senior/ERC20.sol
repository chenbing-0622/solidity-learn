// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

interface IERC20 {
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address recipient, uint256 amount) external returns(bool);
    function allowance(address owner, address spender) external view returns(uint256);
    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
}

contract ERC20 is IERC20 {
    /*
        状态变量可以自动生成 getter 函数,相当于:
        function totalSupply() public view returns (uint256) {
            return _totalSupply;
        }
        所以使用状态变量可以替代函数实现
    */ 
    
    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    mapping(address => mapping(address => uint)) public allowance;

    string public name = "Test";
    string public symbol = "Test";
    uint8 public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);
    // owner允许spender花费的金额
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function transfer(address recipient, uint256 amount) external returns(bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns(bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool){
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}