// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/*
    时间锁是一种机制，要求某些操作在提议后必须等待一段时间才能执行。这段时间让社区成员可以审查提议的操作，如果发现问题可以采取应对措施
*/
contract TimeLock {
    error NotOwnerError();
    error AlreadyQueuedError(bytes32 txId);
    error TimestampNotInRangeError(uint blockTimestamp, uint timestamp);
    error NotQueuedError(bytes32 txId);
    error TimestampNotPassedError(uint blockTimestamp, uint timestamp);
    error TimestampExpiredError(uint blockTimestamp, uint expiredAt);
    error TxFailedError();

    event Queue(bytes32 indexed txId, address indexed target, uint value, string func, bytes data, uint timestamp);

    event Execute(bytes32 indexed txId, address indexed target, uint value, string func, bytes data, uint timestamp);

    event Cancel(bytes32 indexed txId);

    uint public constant MIN_DELAY = 10; // 最小延迟时间, 防止瞬时执行
    uint public constant MAX_DELAY = 1000; // 最大延迟时间, 防止无限期拖延
    uint public constant GRACE_PERIOD = 1000; // 宽限期（操作必须在此期限内执行）

    address public owner;
    mapping(bytes32 => bool) public queued;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable { }

    modifier onlyOwner (){
        if(msg.sender != owner){
            revert NotOwnerError();
        }
        _;
    }

    function getTxId(address _target, uint _value, string calldata _func, bytes calldata _data, uint _timestamp) public pure returns(bytes32 txId) {
        return keccak256(abi.encode(_target, _value, _func, _data, _timestamp));
    }

    function queue(address _target, uint _value, string calldata _func, bytes calldata _data, uint _timestamp) external onlyOwner{
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        if(queued[txId]){
            revert AlreadyQueuedError(txId);
        }

        // ---|------------|---------------|-------
        // block block + min block + max
        if ( _timestamp < block.timestamp + MIN_DELAY ||  _timestamp > block.timestamp + MAX_DELAY) {
            revert TimestampNotInRangeError(block.timestamp, _timestamp);
        }

        // queue tx
        queued[txId] = true;

        emit Queue(txId, _target, _value, _func, _data, _timestamp);
    }

    function execute(address _target, uint _value, string calldata _func, bytes calldata _data, uint _timestamp) external payable onlyOwner returns (bytes memory) {
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        // check tx is queued
        if( !queued[txId]){
            revert NotQueuedError(txId);
        }
        // check block.timestamp > _timestamp，当前时间小于传入的时间戳就表示未到执行时间
        if( block.timestamp < _timestamp) {
            revert TimestampNotPassedError(block.timestamp, _timestamp);
        }
        // ----|-------------------|-------
        // timestamp timestamp + grace period   操作必须在此期限内执行
        if(block.timestamp > _timestamp + GRACE_PERIOD){
            revert TimestampExpiredError(block.timestamp, _timestamp + GRACE_PERIOD);
        }

        queued[txId] = false;

        bytes memory data;
        if(bytes(_func).length > 0) {
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
        } else{
            data = _data;
        }

        // execute the tx
        (bool ok, bytes memory res) = _target.call{value: _value}(data);
        if(!ok){
            revert TxFailedError();
        }

        emit Execute(txId, _target, _value, _func, _data, _timestamp);
        return res;
    }

    function cancel(bytes32 _txId) external onlyOwner{
        if(!queued[_txId]){
            revert NotQueuedError(_txId);
        }
        queued[_txId] = false;
        emit Cancel(_txId);
    }
}

contract TestTimeLock{
    address public timeLock;

    constructor(address _timeLock){
        timeLock = _timeLock;
    }

    function test() external {
        require(msg.sender == timeLock);
        // more code such as
        // - 升级合约
        // - 转移资产
        // - 修改预⾔机
    }

    function getTimestamp() external view returns(uint){
        return block.timestamp + 100;
    }
}