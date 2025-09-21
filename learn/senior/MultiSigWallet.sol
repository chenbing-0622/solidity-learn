// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

/*
    该合约是一个多签钱包（Multi-Signature Wallet），用于管理需要多个所有者共同授权才能执行的交易
    多重签名机制：
        需要 N 个所有者中至少 M 个（required）授权，才能执行一笔交易（例如，3个所有者中至少2人同意）
*/
contract MultiSigWallet {
    // 用户存钱会触发该事件
    event Deposit(address indexed sender, uint amount);
    // 任何所有者可以提交一笔待执行的交易
    event Submit(uint indexed txId);
    // 其他所有者可以对交易进行授权
    event Approved(address indexed owner, uint indexed txId);
    // 所有者可以撤回自己的授权
    event Revoke(address indexed owner, uint indexed txId);
    // 当授权数量达到阈值（required）时，交易被执行
    event Execute(uint indexed txId);
    
    // 交易对象
    struct Transaction {
        address to; // 发给谁
        uint value; // 发多少以太
        bytes data;
        bool executed; // 交易有没有执行过
    }

    // 所有所有者的地址列表
    address[] public owners;
    // 所有者是否存在
    mapping(address => bool) public isOwner;
    // 执行交易所需的最小授权数量
    uint public required;
    // 存储所有提交的交易
    Transaction[] public transactions;
    // 记录每笔交易被哪些所有者授权
    mapping(uint => mapping(address => bool)) public approved;

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "owners require");
        require(_required > 0 && _required <= _owners.length, "invalied required number");
        
        // 保存传入的合约的所有者，设置执行交易所需的最小授权数量
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalied owner");
            require(!isOwner[owner], "owner is not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;
    }

    // 限制仅所有者可调用
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    // 检查交易 ID 是否存在
    modifier txExists(uint _txId) {
        require(_txId < transactions.length, "tx does not exist");
        _;
    }

    // 检查调用者是否已授权该交易（避免重复）
    modifier notApproved(uint _txId) {
        require(!approved[_txId][msg.sender], "tx already approved");
        _;
    }

    // 检查交易是否已执行（避免重放）
    modifier notExecuted(uint _txId) {
        require(!transactions[_txId].executed, "tx already executed");
        _;
    }

    // 接收到用户存入的钱(以太)
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submit(address _to, uint _value, bytes calldata _data) external onlyOwner {
        transactions.push(Transaction(_to, _value, _data, false));
        emit Submit(transactions.length - 1);
    }

    // 给某一笔交易授权，允许执行该交易
    function approve(uint _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        emit Approved(msg.sender, _txId);
    }

    // 拿到某一笔交易已授权的数量
    function _getApprovalCount(uint _txId) private view returns (uint count) {
        for(uint i = 0; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) {
                count += 1;
            }
        }
    }

    // 执行交易
    function execute(uint _txId) external txExists(_txId) notExecuted(_txId) {
        require(_getApprovalCount(_txId) >= required, "approved < required");
        Transaction storage transaction = transactions[_txId];

        transaction.executed = true;

        (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "tx failed");
        emit Execute(_txId);
    }

    // 解除授权
    function revoke(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        require(approved[_txId][msg.sender], "tx not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }
}