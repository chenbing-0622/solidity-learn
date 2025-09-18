// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

interface ICounter{

    function count() external view returns(uint);

    function increment() external;
}

contract MyContract {
    function incrementCounter(address _counter) external {
        ICounter(_counter).increment();
    }

    // Solidity 会自动为 public 状态变量生成同名的 getter 函数，因此可以通过.count()调用
    function getCount(address _counter) external view returns(uint) {
        return ICounter(_counter).count();
    }
}