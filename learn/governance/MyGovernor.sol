// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

/**
 * @title SimpleGovernor - 完整可工作的简化治理合约
 */
contract SimpleGovernor is Governor, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction {
    // 硬编码参数，简化设置
    uint256 public constant VOTING_DELAY = 1;    // 1 区块
    uint256 public constant VOTING_PERIOD = 2; // 2 区块
    uint256 public constant PROPOSAL_THRESHOLD = 0; // 100 个代币

    constructor(IVotes _token)
        Governor("SimpleGovernor")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4) // 4% 法定人数
    {}

    // 简化参数设置
    function votingDelay() public pure override returns (uint256) {
        return VOTING_DELAY;
    }

    function votingPeriod() public pure override returns (uint256) {
        return VOTING_PERIOD;
    }

    function proposalThreshold() public pure override returns (uint256) {
        return PROPOSAL_THRESHOLD;
    }
}