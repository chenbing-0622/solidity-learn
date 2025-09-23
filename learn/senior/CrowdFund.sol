// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
}

// 部署测试
// 账户 1（deployer）：-> launch
// 账户 2 -> pledge
// 账户 3 -> pledge
/*
    众筹：是一种资金募集的方式，发起者通过某个公开平台向大众募集资金，目标是用这些资金启动或推动某个项目、产品或社会事业。
          随着web3技术的兴起，智能合约去中心化的方式使得众筹活动更加公正和高效，资金流动更加安全与透明。
*/
contract CrowdFund {
    // 创建众筹活动
    event Launch(uint id, address indexed creator, uint goal, uint32 startAt, uint32 endAt);
    // 取消未开始的众筹
    event Cancel(uint id);
    // 认捐资金
    event Pledge(uint indexed id, address indexed caller, uint amount);
    // 撤回认捐
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    // 众筹成功后提取资金
    event Claim(uint id);
    // 众筹失败后退款
    event Refund(uint indexed id, address indexed caller, uint amount);

    struct Campaign {
        address creator; // 存储众筹的创建者
        uint goal;  // 目标金额
        uint pledged; // 已认捐金额
        uint32 startAt; // 活动计划开始时间
        uint32 endAt;  // 活动计划结束时间
        bool claimed; // 提取状态
    }

    IERC20 public immutable token;
    uint public count; // 记录众筹轮次
    mapping (uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledgedAmount; // 记录每个用户在每个众筹中的认捐金额

    constructor(address _token) {
        token = IERC20(_token);
    }

    // 发起众筹
    function launch(uint _goal, uint32 _startOffset, uint32 _endOffset) external {
        require(_endOffset > _startOffset, "endAt <= startAt");
        require(_endOffset <= 30 days, "end > 30 days");

        uint32 _startAt = uint32(block.timestamp) + _startOffset;
        uint32 _endAt = uint32(block.timestamp) + _endOffset;

        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });
        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    // 取消众筹（只能在众筹活动开始之前取消）
    function cancel(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp < campaign.startAt, "started");

        delete campaigns[_id];
        emit Cancel(_id);
    }

    // 认捐资金
    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        
        require(block.timestamp >= campaign.startAt, "not started");
        require(block.timestamp <= campaign.endAt, "ended");

        campaign.pledged += _amount; // 活动累计捐赠金额
        pledgedAmount[_id][msg.sender] += _amount; // 活动个人累计捐赠金额

        token.transferFrom(msg.sender, address(this), _amount);
        emit Pledge(_id, msg.sender, _amount);
    }

    // 撤回认捐（活动结束前才能撤回）
    function unpledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];

        require(block.timestamp <= campaign.endAt, "ended");
        campaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }


    // 提取资金
    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged >= campaign.goal, "pledged < goal");
        require(!campaign.claimed, "claimed");
        campaign.claimed = true;

        token.transfer(msg.sender, campaign.pledged);
        emit Claim(_id);
    }

    // 失败退款（众筹失败后，用户可退回其认捐金额）
    function refund(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged < campaign.goal, "pledged >= goal");

        uint bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }
}