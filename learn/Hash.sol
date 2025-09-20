// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract Hash {

    // keccak256：生成固定32字节的哈希值
    // abi.encode: 有填充，固定32字节，如果参数数据超过32字节，会以32字节的倍数扩容
    // abi.encodePacked：无填充，将多个参数紧密打包（不含填充）连接成一个连续的 bytes 数组
    function hash(string memory text, uint num, address addr) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(text, num, addr));
    }

    function encode(string memory text0, string memory text1) external pure returns(bytes memory) {
        return abi.encode(text0, text1);
    }

    function encodePacked(string memory text0, string memory text1) external pure returns (bytes memory) {
        return abi.encodePacked(text0, text1);
    }
    
    function collision(string memory text0, uint x, string memory text1) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(text0, x, text1));
    }
}

contract VerifySig {

    /*
        测试步骤：
            1、F12->Console->window.ethereum.request({ method: 'eth_requestAccounts' }) （连接小狐狸钱包）
            2、ethereum.enable()，Promise对象的PromiseState的值是"fulfilled"表示小狐狸启动成功
            3、输入account = 小狐狸钱包的账户地址, 输入hash = getMessageHash()函数生成的哈希
            4、输入ethereum.request({method: "personal_sign", params:[account, hash]}),回车后会弹出消息框，
            点击Sign,Promise对象的PromiseResult的值就是生成的签名串
    */
    function verify(address _signer, string memory _message, bytes memory _sig) external pure returns(bool){
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recover(ethSignedMessageHash, _sig) == _signer;
    }

    function getMessageHash(string memory _message) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns(bytes32) {
        /* 
            添加以太坊签名前缀（防止跨合约、应用重放攻击），这个前缀就像在签名消息上盖了一个"仅限本店使用"的印章。
            该前缀是MetaMask 推广并成为事实上的行业标准。可以自定义前缀，但也需要自定义钱包，不能使用标准钱包
            \x19        - 魔术字节，传统上用于版本控制和类型标识
            "Ethereum Signed Message:" - 明确的消息域和上下文
            "\n32"      - 消息长度（防止长度扩展攻击）
        */
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }


    /* ecrecover:用于从数字签名中恢复出签名者的以太坊地址
        function ecrecover(
            bytes32 hash,      // 被签名的消息的哈希值
            uint8 v,           // 恢复ID (recovery id)
            bytes32 r,         // ECDSA签名的一部分
            bytes32 s          // ECDSA签名的一部分
        ) returns (address);   // 返回恢复出的地址
    */
    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns(address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }



    function _split(bytes memory _sig) internal pure returns(bytes32 r, bytes32 s, uint8 v) {
        require(_sig.length == 65, "invalid signature length");

        /*
            1、一个完整的以太坊签名是65字节，结构如下： [32字节 r] [32字节 s] [1字节 v]
            2、内存布局：
                位置 0-31:  签名长度信息（跳过）
                位置 32-63: r值（32字节）
                位置 64-95: s值（32字节）  
                位置 96:    v值（1字节）
            3、add(_sig, 32)：跳到第32字节的位置（跳过前32字节的长度信息），返回值是address
            4、mload(...)：每次读取32字节（bytes32类型），mload(add(_sig, 32))：从指定内存起始位置开始加载32字节的数据
            5、byte(0, mload(add(_sig, 96))) 获取32位字节的第一个字节
        */
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }
}