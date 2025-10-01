// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

interface IERC20 {
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address recipient, uint256 amount) external returns(bool);
    function allowance(address owner, address spender) external view returns(uint256);
    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(address spender, address recipient, uint256 amount) external returns(bool);
}

contract DiscreteStakingRewards {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;

    mapping(address => uint) public balanceOf; // ⽤⼾质押的代币数量
    uint public totalSupply; // 总质押量

    uint private constant MULTIPLIER = 1e18;
    uint private rewardIndex;
    mapping(address => uint) private rewardIndexOf; // 记录用户上次提取时的每质押代币应得奖励
    mapping(address => uint) private earned; // 用户总共获得的奖励

    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    // 更新奖励指数：管理员设置奖励代币，奖励指数会重新计算
    function updateRewardIndex(uint256 reward) external {
        rewardToken.transferFrom(msg.sender, address(this), reward); 
        rewardIndex += (reward * MULTIPLIER) / totalSupply;
    }

    // 计算奖励
    function _calculateRewards(address account) private view returns(uint){
        uint shares = balanceOf[account];
        return (shares * (rewardIndex - rewardIndexOf[account]))/ MULTIPLIER;
    }

    // 计算用户总共获得的奖励
    function calculateRewardEarned(address account) external view returns(uint){
        return earned[account] + _calculateRewards(account);
    }

    // 更新⽤⼾奖励：避免重复计算从最开始到现在的所有收益
    function _updateRewards(address account) private {
        earned[account] += _calculateRewards(account);
        rewardIndexOf[account] = rewardIndex;
    }

    // 质押
    function stake(uint amount) external {
        _updateRewards(msg.sender);
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);
    }

    // 取消质押
    function unstake(uint amount) external {
        _updateRewards(msg.sender);
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;

        stakingToken.transfer(msg.sender, amount);
    }

    // 领取奖励
    function claim() external returns(uint) {
        _updateRewards(msg.sender);
        uint reward = earned[msg.sender];

        if(reward > 0){
        earned[msg.sender] = 0;
        rewardToken.transfer(msg.sender, reward);
        }

        return reward;
    }
}