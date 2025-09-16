// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract E {
    event Log(string message);

    function foo() public virtual {
        emit Log("E.foo");
    }

    function bar() public virtual {
        emit Log("E.bar");
    }
}

contract F is E {
    function foo() public virtual override {
        emit Log("F.foo");
        // 可以直接通过父类名E调用函数
        E.foo();
    }

    function bar() public virtual override {
        emit Log("F.bar");
        // super.bar：表示当前继承的父类去调用函数
        super.bar();
    }
}

contract G is E {
    function foo() public virtual override {
        emit Log("G.foo");
        E.foo();
    }

    function bar() public virtual override {
        emit Log("G.bar");
        super.bar();
    }
}

/**
 *     E
 *    / \
 *   F   G
 *    \ /
 *     H
 * super调用规则：
 *      1、solidity使用C3线性化算法，super 调用遵循 H → G → F → E，确保每个父类方法只调用一次。
 *      2、同一个父类方法（如 E.bar）在继承链中只会被执行一次
 * 如果希望 E.bar() 被调用两次，就需要显式调用 F.bar() 和 G.bar()：
 *      function bar() public override(F, G) {
 *          F.bar(); // 触发 F.bar → E.bar
 *           G.bar(); // 触发 G.bar → E.bar
 *       }
 */
contract H is F,G {
    function foo() public override(F,G) {
        F.foo();
    }

    function bar() public override(F,G) {
        // 因为继承了两个父合约，所以会去调用F的bar函数和G的bar函数
        super.bar();
    }
}