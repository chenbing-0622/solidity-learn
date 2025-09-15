// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract DataLocations {
    struct MyStruct {
        uint256 foo;
        string text;
    }

    mapping(address => MyStruct) myStructs;

    function example(uint[] memory y, string memory s) external returns(uint[] memory) {
        myStructs[msg.sender] = MyStruct({foo: 123, text: "bar"});

        MyStruct storage myStruct = myStructs[msg.sender];
        myStruct.text = "foo";

        MyStruct memory readOnly = myStructs[msg.sender];
        readOnly.foo = 456;

        uint[3] memory arrFixed = [uint(1), uint(2), uint(3)];
        uint[] memory memArr = new uint[](3);
        memArr[0] = 234;
        return memArr;
    }

    // memory需要把数据复制到内存，calldata的数据直接来自交易或消息调用的字节流，由 EVM 管理，无需手动复制。所以calldata更节省gas
    function _internal(uint[] calldata y) private {
        uint x = y[0];
    }
}