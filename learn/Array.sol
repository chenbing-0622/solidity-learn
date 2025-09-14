// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract Array {

    uint[] public arr = [1, 2, 3];

    uint[3] public arrFixed = [1, 2, 3];

    function examples() external{
        arr.push(4); // [1, 2, 3, 4]
        uint x = arr[1]; // 2
        arr[2] = 777; // [1, 2, 777, 4]
        delete arr[1]; // [1, 0, 777, 4] delete只会清空数据并不会删除元素
        arr.pop(); // [1, 0, 777] 数组不支持删除指定元素
        uint len = arr.length; // 3

        // memory关键字：创建存放在内存中的数组:
        // 1. 数据临时存在内存中，函数结束后销毁
        // 2. 可修改，但不能调用 push/pop（长度固定）
        // 3. 常用于返回动态数据或临时计算
        uint[] memory a = new uint[](5);
        a[1] = 123;
    }
    
    // 不建议返回数组，因为对gas消耗会变高
    function returnArray() external view returns(uint[] memory) {
        return arr;
    }
}