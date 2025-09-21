// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/*
    EOA:用户发起

    调用场景	                        在目标函数中msg.sender的值	            备注
    EOA -> 合约A	                    EOA 地址	                           最基础的直接调用
    EOA -> 合约A -> 合约B	            合约A 的地址	                        核心要点：是直接调用者，而非起源
    EOA -> 合约A delegatecall合约B	    EOA 的地址	                           delegatecall 保持调用者上下文
    EOA 部署合约A	                    EOA 地址 (在构造函数中)	                部署者是 msg.sender
    内部函数调用	                    保持不变 (与外部函数相同)	             内部调用不改变调用上下文
*/
interface IERC721 {
    function transferFrom (
        address _from,
        address _to,
        uint _nftId
    ) external;
}

/*
    荷兰拍卖：又称减价拍卖，价格是从一个较高的起始价开始，并随着时间的推移逐渐下降，直到有买家愿意接受当前的价格，则拍卖结束
    例子：荷兰式拍卖数字藏品
        -: 6000$ （起拍）
        -: 5000$
        -: 4000$
        A: 3000$ （成交）
*/
contract DutchAuction {
    
    // NFT 相关信息
    IERC721 public immutable nft;
    uint public immutable nftId;

    // 拍卖信息
    uint private constant DURATION = 7 days; // 拍卖有效期
    address public immutable seller; // 卖方
    uint public immutable startingPrice; // 起拍价格
    uint public immutable startAt; // 开始时间
    uint public immutable expiresAt; // 结束时间
    uint public immutable discountRate; // 降价步长, 例如起拍6000，定义1000的话，后续每一次降1000

   // 卖家出售 NFT
   constructor(
        uint _startingPrice,
        uint _discountRate,
        address _nft,
        uint _nftId
   )
   {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;

        require( _startingPrice >= _discountRate * DURATION, "starting price < discount");

        nft = IERC721(_nft);
        nftId = _nftId;
   }

   // 买家购买 NFT
    function buy() external payable {
        require(block.timestamp < expiresAt, "aution expired");

        uint price = getPrice();
        require(msg.value >= price, "ETH < price");

        nft.transferFrom(seller, msg.sender, nftId);
        uint refund = msg.value - price;
        if(refund > 0) {
            payable (msg.sender).transfer(refund);
        }
    }

    // 查看当前价格
    function getPrice() public view returns(uint) {
        uint timeElapsed = block.timestamp - startAt;
        uint discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }
}