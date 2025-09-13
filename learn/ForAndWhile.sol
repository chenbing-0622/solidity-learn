// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract ForAndWhile {
    function loops() external pure {
        for (uint i = 0; i < 10; i++) {
            if (i == 3) {
                continue;
            }

            if (i == 5) {
                break;
            }
        }
        uint j = 0;
        while(j < 10) {
            j++;
        }
    }
    // 代码逻辑处理越多，gas费越多
    function sum(uint n) external pure returns(uint){
        uint s;
        for (uint i = 0; i < n; i++) {
            s += 1;
        }
        return s;
    }

    function gas() external pure {
    }
}