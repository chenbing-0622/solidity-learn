// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

/*
    质押与奖励：用户存入某种代币，然后根据他们存入的份额和时间，获得另一种代币作为奖励
*/
contract StakingRewards {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;
    address public owner;
    uint256 public duration; // 奖励持续时间
    uint256 public finishAt; // 奖励结束的时间戳
    uint256 public updatedAt; // 奖励累积的开始时间
    uint256 public rewardRate;  // 奖励速率（每秒发放的奖励数量）
    uint256 public rewardPerTokenStored;  // 累计的每质押代币应得奖励(累积的每个质押的代币值多少奖励)

    mapping(address => uint256) public userRewardPerTokenPaid; // 记录用户上次更新时的每个质押代币应得奖励
    mapping(address => uint256) public rewards; // 用户已累计但未领取的奖励

    uint256 public totalSupply; // 所有用户当前质押代币的总量
    mapping(address => uint256) public balanceOf; // 每个用户质押的代币数量

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();

        if (_account != address(0)) {
            // 获取用户已累计但未领取的奖励
            rewards[_account] = earned(_account);
            /*
                避免重复计算从最开始到现在的所有收益
                时间轴: 0----A----B----C---D
                收益段:   段1  段2  段3
                用户第一次领取了0-A的收益，下次领取收益就不能从0开始，而是领取A-B的收益
                userRewardPerTokenPaid就是为了标记新的起点，用户领取了0-A的收益，下次的起点就是A，而不是0
            */
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }

        _;
    }

    constructor(address _stakingToken, address _rewardsToken) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    function setRewardsDuration(uint256 _duration) external onlyOwner {
        // 防止在奖励周期进行中修改奖励持续时间
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }

    // 由所有者调用，向合约注入新的奖励代币，并设置新的奖励速率
    function notifyRewardAmount(uint256 _amount) external onlyOwner updateReward(address(0)) {
        if (block.timestamp > finishAt) {
            // 计算每秒发放多少奖励代币（DeFi奖励分配的标准数学模型，公式：总奖励 = 奖励率 × 持续时间）
            // 确保每个时间段奖励相同、用户可以准确计算收益、无法通过时间选择获得额外优势
            rewardRate = _amount / duration;
        } else {
            // 计算剩余未发放的奖励：剩余奖励代币 = 奖励率 * (结束时间 - 当前时间)
            uint256 remainingRewards = rewardRate * (finishAt - block.timestamp);
            // 计算新的奖励速率
            rewardRate = (remainingRewards + _amount) / duration;
        }
        require(rewardRate > 0, "reward rate = 0");
        require(rewardRate * duration <= rewardsToken.balanceOf(address(this)), "reward amount > balance");
        finishAt = block.timestamp + duration; // 奖励周期的绝对结束时间戳（例如 block.timestamp + 7 天）
        updatedAt = block.timestamp; // 从当前时间开始计算新的奖励累积
    }

    function stake(uint256 _amount) external updateReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;
    }

    function withdraw(uint256 _amount) external updateReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        stakingToken.transfer(msg.sender, _amount);
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return _min(block.timestamp, finishAt);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        /*
            已发放奖励代币 = 奖励速率 * 已过去的时间
            每个质押代币应得奖励 = 已发放奖励代币 / 总质押代币
        */
        return rewardPerTokenStored + ((rewardRate * (lastTimeRewardApplicable() - updatedAt)) * 1e18) / totalSupply;
    }

    // 显示用户获得的奖励代币
    function earned(address _account) public view returns (uint256) {
        return (balanceOf[_account] * (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18 + rewards[_account];
    }

    function getReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }

    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }
}