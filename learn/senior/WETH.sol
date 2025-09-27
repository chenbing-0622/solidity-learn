// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
    WETH:代表"包装的以太"，是⼀种将以太（ETH）包装为ERC20标准代币的⽅法。⽤⼾
    存⼊ETH时，将铸造出对应的ERC20代币；⽤⼾提取时，相应的ERC20代币将被销毁

    合约简化: 使⽤WETH可以避免编写两个分离的合约（⼀个针对ETH，⼀个针对ERC20代币）。通过
    交互WETH，任何⽀持ERC20的合约都可以间接⽀持ETH。
*/
contract WETH is ERC20 {

    event Deposit(address indexed account, uint amount);

    event Withdraw(address indexed account, uint amount);

    constructor() ERC20 ("Wrapped Ether", "WETH"){}

    fallback() external payable {
        deposit();
    }

    function deposit() public payable{
        _mint(msg.sender, msg.value); // ERC20库的方法，用于铸造ERC20代币
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint _amount) external {
        _burn(msg.sender, _amount); // ERC20库的方法，用于销毁ERC20代币
        payable(msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }
}