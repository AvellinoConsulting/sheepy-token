// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "solady/utils/ReentrancyGuard.sol";
import "solady/auth/Ownable.sol";
import {Sheepy404Mirror} from "./Sheepy404Mirror.sol";
import {Sheepy404} from "./Sheepy404.sol";
import {MissionRewardManager} from "./MissionRewardManager.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract MoonsheepMissionGame is ReentrancyGuard, Ownable, IERC721Receiver {
    error NotNFTOwner();
    error NFTAlreadyOnMission();
    error NoHyperspaceCredits();
    error MissionNotCompleted();
    error MissionAlreadyCompleted();
    error RewardTransferFailed();

    struct Mission {
        address owner;
        uint32 startTime;
        uint256 tokenId;
        bool completed;
    }

    Sheepy404Mirror public immutable sheepy404Mirror;
    Sheepy404 public immutable sheepy404;
    MissionRewardManager public rewardManager;
    uint256 public immutable missionDuration;
    address public sheepyHolder;
    mapping(uint256 => Mission) public activeMissions;
    mapping(address => uint256) public hyperspaceCredits;

    event MissionStarted(address indexed user, uint256 indexed tokenId, uint256 startTime);
    event MissionCompleted(address indexed user, uint256 tokenId, uint256 rewardAmount, bool wonHyperspace);
    event HyperspaceUsed(address indexed user, uint256 indexed tokenId);

    constructor(address payable _sheepy404mirror, address payable _sheepToken, address _rewardManager, uint256 _missionDuration) Ownable() {
        _initializeOwner(msg.sender);
        require(_sheepToken != address(0), "Invalid SHEEP token");
        require(_sheepy404mirror != address(0), "Invalid NFT contract");
        require(_rewardManager != address(0), "Invalid Reward Manager");
        require(_missionDuration > 0, "Invalid mission duration");

        sheepy404 = Sheepy404(_sheepToken);
        sheepy404Mirror = Sheepy404Mirror(_sheepy404mirror);
        rewardManager = MissionRewardManager(_rewardManager);
        missionDuration = _missionDuration;
    }

    function setSheepyHolder(address _sheepyHolder) external onlyOwner {
        require(_sheepyHolder != address(0), "Invalid address");
        sheepyHolder = _sheepyHolder;
    }

    function startMission(uint256 tokenId) external nonReentrant {
        if (sheepy404Mirror.ownerOf(tokenId) != msg.sender) revert NotNFTOwner();
        if (activeMissions[tokenId].owner != address(0)) revert NFTAlreadyOnMission();

        // Transfer NFT to contract
        sheepy404Mirror.safeTransferFrom(msg.sender, address(this), tokenId, "0xnull");

        activeMissions[tokenId] = Mission({
            owner: msg.sender,
            tokenId: tokenId,
            startTime: uint32(block.timestamp),
            completed: false
        });

        emit MissionStarted(msg.sender, tokenId, block.timestamp);
    }

    function startMissionWithHyperspace(uint256 tokenId) external nonReentrant {
        if (sheepy404Mirror.ownerOf(tokenId) != msg.sender) revert NotNFTOwner();
        if (activeMissions[tokenId].owner != address(0)) revert NFTAlreadyOnMission();
        if (hyperspaceCredits[msg.sender] == 0) revert NoHyperspaceCredits();

        hyperspaceCredits[msg.sender]--;
        emit HyperspaceUsed(msg.sender, tokenId);
        _completeMission(msg.sender, tokenId, false);
    }

    function completeMission(uint256 tokenId) external nonReentrant {
        Mission storage mission = activeMissions[tokenId];
        if (mission.owner != msg.sender) revert NotNFTOwner();
        if (block.timestamp < mission.startTime + missionDuration) revert MissionNotCompleted();
        if (mission.completed) revert MissionAlreadyCompleted();

        _completeMission(msg.sender, tokenId, true);
    }

    function _completeMission(address owner, uint256 tokenId, bool isStandardMission) internal {
        if (isStandardMission) {
            Mission storage mission = activeMissions[tokenId];
            mission.completed = true;
        }

        (uint256 rewardAmount, uint256 hyperspaceRewards) = rewardManager.calculateRewards(owner, isStandardMission);

        if (rewardAmount > 0) {
            if (!sheepy404.transferFrom(sheepyHolder, owner, rewardAmount)) revert RewardTransferFailed();
        }
        
        if (hyperspaceRewards > 0) {
            hyperspaceCredits[owner] += hyperspaceRewards;
        }

        // Return NFT to the owner if it was a standard mission
        if (isStandardMission) {
            sheepy404Mirror.safeTransferFrom(address(this), owner, tokenId, "0xnull");
            delete activeMissions[tokenId];
        }

        emit MissionCompleted(owner, tokenId, rewardAmount, hyperspaceRewards > 0);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        (operator);
        (from);
        (tokenId);
        (data);
        return IERC721Receiver.onERC721Received.selector;
    }
}
