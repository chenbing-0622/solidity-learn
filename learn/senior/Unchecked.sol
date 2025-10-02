// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

/*
    Solidity 0.8.0 及以上版本支持unchecked，针对算术使用
    1、只在确定不会溢出时使用
    2、优先在循环计数器中使用
    3、必要时先进行手动检查
*/
contract UncheckedMath {
    function add(uint256 x, uint256 y) external pure returns(uint256) {
        // 926 gas
        return x + y;

        // 747
        // unchecked {
        //     return x + y;
        // }
    }

    function sub(uint256 x, uint256 y) external pure returns(uint256) {
        // 970 gas
        return x - y;

        // 791
        // unchecked {
        //     return x - y;
        // }
    }

    function sumOfCubes(uint256 x, uint256 y) external pure returns(uint256) {
        // 1964 gas
        uint256 x3 = x * x * x;
        uint256 y3 = y * y * y;
        return x3 + y3;

        // 825
        // unchecked {
        //     uint256 x3 = x * x * x;
        //     uint256 y3 = y * y * y;
        //     return x3 + y3;
        // }
    }
}