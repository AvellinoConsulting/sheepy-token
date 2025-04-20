// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "solady/auth/Ownable.sol";

contract MissionRewardManager is Ownable {
    event RewardCalculated(address indexed user, uint256 rewardAmount, uint256 hyperspaceRewards);

    struct Reward {
        uint256 amount;
        uint256 odds; // e.g., 10 means 1 in 10 chance
    }

    Reward[] public rewards;
    uint256 public hyperspaceRewardAmount;
    uint256 public hyperspaceRewardOdds; // e.g., 5 means 1 in 5 chance

    constructor() {
        hyperspaceRewardAmount = 3;
        hyperspaceRewardOdds = 5; // Most common reward
        rewards.push(Reward(1*10e18, 1));
    }

    function addReward(uint256 amount, uint256 odds) external onlyOwner {
        rewards.push(Reward(amount, odds));
    }

    function setHyperspaceRewardAmount(uint256 amount) external onlyOwner {
        hyperspaceRewardAmount = amount;
    }

    function setHyperspaceRewardOdds(uint256 odds) external onlyOwner {
        hyperspaceRewardOdds = odds;
    }

    function calculateRewards(address user, bool isStandardMission) external returns (uint256 rewardAmount, uint256 hyperspaceRewards) {
        (isStandardMission);
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, user))) % 1000;

        for (uint256 i = 0; i < rewards.length; i++) {
            if (random < (1000 / rewards[i].odds)) {
                rewardAmount = rewards[i].amount;
                break;
            }
        }

        if (rewardAmount == 0 && random < (1000 / hyperspaceRewardOdds)) {
            hyperspaceRewards = hyperspaceRewardAmount;
        }

        emit RewardCalculated(user, rewardAmount, hyperspaceRewards);
    }
}