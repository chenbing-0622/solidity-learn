// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract ArrayReplaceLast {

    uint[] public arr;

    // 交换元素，指定数组元素与最后一位元素交换位置后删除最后一位元素，节省gas消耗
    function remove(uint index) public {
        arr[index] = arr[arr.length - 1];
        arr.pop();
    }

    function test() external {
        arr = [1, 2, 3, 4];
        remove(1);

        assert(arr.length == 3);
        assert(arr[0] == 1);
        assert(arr[1] == 4);
        assert(arr[2] == 3);

        remove(2);

        assert(arr.length == 2);
        assert(arr[0] == 1);
        assert(arr[1] == 4);
    }
}