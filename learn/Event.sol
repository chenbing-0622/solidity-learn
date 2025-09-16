// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract Event {
    event Log(string message, uint val);
    event IndexLog(address indexed sender, uint val);

    function exampl() external {
        emit Log("foo", 1234);
        emit IndexLog(msg.sender, 789);
    }

    event Message(address indexed _from, address indexed _to, string message);

    function sendMessage(address _to, string calldata message) external {
        emit Message(msg.sender, _to, message);
    }
}