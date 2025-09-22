// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

interface IERC721 {
 	function transferFrom (
 		address _from,
 		address _to,
 		uint _nftId
 	) external;
}

/*
    英式拍卖：拍卖开始于一个最低价或起拍价，竞标者根据自己的意愿竞价，且每次出价必须高于上一个出价者，直到没人愿意加价为止，
             最终，出价最高的竞标者赢得拍卖品。常见于艺术品、古董、房产等高价值物品的拍卖。
    例子：英式拍卖一件艺术品
        -: 10000$ （起拍）
        A: 12000$
        B: 15000$
        C: 30000$ （成交）
*/
contract EnglishAuction {
    event Start(); // 拍卖启动
    event Bid(address indexed sender, uint amount); // 记录竞价
    event Withdraw(address indexed bidder, uint amount); // 记录提款
    event End(address highestBidder, uint highestBid); // 拍卖结束

    // NFT 相关信息
    IERC721 public immutable nft;
    uint public immutable nftId;

    // 拍卖信息
    address payable  public immutable seller; // 卖方
    uint32 public endAt; // 拍卖结束时间
    bool public started; // 拍卖开始状态
    bool public ended; // 拍卖结束状态

    address public highestBidder; // 当前最高价买家
    uint public highestBid;  // 当前最高价
    mapping(address => uint) public bids; // 记录每个买家的累计竞价金额

    // 初始化
    constructor(
        address _nft,
        uint _nftId,
        uint _startingBid
    ){
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable (msg.sender);
        highestBid = _startingBid;
    }

    // 卖家发起拍卖
    function start() external {
        require(msg.sender == seller, "not seller");
        require(!started, "started");

        started = true;
        endAt = uint32(block.timestamp + 600);
        nft.transferFrom(seller, address(this), nftId);

        emit Start();
    }

    // 买家竞价
    function bid() external payable {
        require(started, "not started");
        require(block.timestamp < endAt, "ended");
        require(msg.value > highestBid, "value < highest bid");

        if(highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;

        emit Bid(msg.sender, msg.value);
    }

    // 买家提款
    function withdraw() external {
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        payable (msg.sender).transfer(bal);
        emit Withdraw(msg.sender, bal);
    }

    // 结束拍卖
    function end() external {
        require(started, "not started");
        require(!ended, "ended");
        require(block.timestamp >= endAt, "not ended");

        ended = true;
        if(highestBidder != address(0)) {
            nft.transferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        }else{
            nft.transferFrom(address(this), seller, nftId);
        }

        emit End(highestBidder, highestBid);
    }
}