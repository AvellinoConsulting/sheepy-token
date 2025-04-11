#!/bin/bash

# Set your environment variables
RPC_URL="https://api.testnet.abs.xyz"
PRIVATE_KEY="0x5a47de970be76260b4ddea9e4e4f4c4ef6344001ebb6b52d96205ad11d7916fd"

# Invoke the reroll function from PRIVATE_KEY_2
PRIVATE_KEY_2="0x4c0883a69102937d6231471b5dbb6204fe512961708279c9c1b5f1b8a5f5c5d8"

TOKEN_IDS="1,2,3" # Replace with actual token IDs
URI_IDS="101,102,103" # Replace with actual URI IDs

# Initialize deployer address
DEPLOYER_ADDRESS="0x86ee94AF5aBB6E2f7073F3B2d0caecA5049F088b"
echo "Deployer address: $DEPLOYER_ADDRESS"

MISSION_DURATION=60

# Build contracts with zkSync
forge build --zksync

# Deploy Sheepy404 contract
SHEEPY404_ADDRESS=$(forge create src/Sheepy404.sol:Sheepy404 --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY | grep 'Deployed to:' | awk '{print $3}')
echo "Sheepy404 deployed to: $SHEEPY404_ADDRESS"

# Deploy Sheepy404Mirror contract
SHEEPY404MIRROR_ADDRESS=$(forge create src/Sheepy404Mirror.sol:Sheepy404Mirror --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY | grep 'Deployed to:' | awk '{print $3}')
echo "Sheepy404Mirror deployed to: $SHEEPY404MIRROR_ADDRESS"

# Deploy SheepySale contract
SHEEPYSALE_ADDRESS=$(forge create src/SheepySale.sol:SheepySale --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY | grep 'Deployed to:' | awk '{print $3}')
echo "SheepySale deployed to: $SHEEPYSALE_ADDRESS"

# Initialize Sheepy404 contract
cast send $SHEEPY404_ADDRESS "initialize(address,address,address,string)" $DEPLOYER_ADDRESS $DEPLOYER_ADDRESS $SHEEPY404MIRROR_ADDRESS "SomethingSomethingNoGrief" --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Initialize SheepySale contract
cast send $SHEEPYSALE_ADDRESS "initialize(address,address,string)" $DEPLOYER_ADDRESS $DEPLOYER_ADDRESS "SomethingSomethingNoGrief" --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Set name and symbol on Sheepy404 contract
cast send $SHEEPY404_ADDRESS "setNameAndSymbol(string,string)" "SheepyToken" "$SHEEP" --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Set base URI on Sheepy404 contract
cast send $SHEEPY404_ADDRESS "setBaseURI(string)" "https://blush-naval-wildcat-408.mypinata.cloud/ipfs/bafybeiav3gfyyzygjtqcfc42druepoty3tdw45gaahq3m5igwdkgcen7eq/{id}.json" --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Set reveal price on Sheepy404 contract
# cast send $SHEEPY404_ADDRESS "setRevealPrice(uint256)" 5000000000000000000 --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Set reroll price on Sheepy404 contract
cast send $SHEEPY404_ADDRESS "setRerollPrice(uint256)" 5000000000000000000 --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Set fee collector on Sheepy404 contract
cast send $SHEEPY404_ADDRESS "setFeeCollector(address)" $DEPLOYER_ADDRESS --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Set base URI on Sheepy404Mirror contract
cast send $SHEEPY404_ADDRESS "setBaseURI(string)" "https://blush-naval-wildcat-408.mypinata.cloud/ipfs/bafybeif6mrlzkjv7km5vtozyvfs5qxjpfxajrohrxlmzl5qut3ejz3yc5m/{id}.json" --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Set name and symbol on Sheepy404 contract
cast send $SHEEPY404_ADDRESS "setNameAndSymbol(string,string)" "SheepyToken" "$SHEEP" --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# transfer $SHEEP to $SHEEPYSALE_ADDRESS
cast send $SHEEPY404_ADDRESS "transfer(address,uint256)" "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" 10090000000000000000000000 --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# transfer $SHEEP to $SHEEPYSALE_ADDRESS
cast send $SHEEPY404_ADDRESS "transfer(address,uint256)" "0x2bd80D4fFFf9C32Fb884cC87c8e4D0880381C517" 1090000000000000000000000 --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Set unrevealed base URI on Sheepy404 contract
cast send $SHEEPY404_ADDRESS "setUnrevealedBaseUri(string)" "https://blush-naval-wildcat-408.mypinata.cloud/ipfs/bafybeidgkd6oxxjumxnfmmcvj727vdb5vqqbfbjl3knsgdbz2426nzpfme/{id}.json" --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

MISSION_REWARD_MANAGER_ADDRESS=$(forge create src/MissionRewardManager.sol:MissionRewardManager --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY | grep 'Deployed to:' | awk '{print $3}')
echo "MissionRewardManager deployed to: $MISSION_REWARD_MANAGER_ADDRESS"

MOONSHEEP_MISSION_GAME_ADDRESS=$(forge create src/MoonsheepMissionGame.sol:MoonsheepMissionGame --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY --constructor-args $SHEEPY404MIRROR_ADDRESS $SHEEPY404_ADDRESS $MISSION_REWARD_MANAGER_ADDRESS $MISSION_DURATION| grep 'Deployed to:' | awk '{print $3}')
echo "MoonsheepMissionGame deployed to: $MOONSHEEP_MISSION_GAME_ADDRESS"

# Set DEPLOYER_ADDRESS as sheepyHolder in MoonsheepMissionGame
cast send $MOONSHEEP_MISSION_GAME_ADDRESS "setSheepyHolder(address)" $DEPLOYER_ADDRESS --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY
echo "Set DEPLOYER_ADDRESS as sheepyHolder in MoonsheepMissionGame"

cast send $SHEEPY404_ADDRESS "approve(address,uint256)" $MOONSHEEP_MISSION_GAME_ADDRESS 99999000000000000000000 --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY
echo "Successfully approved $MOONSHEEP_MISSION_GAME_ADDRESS to spend tokens from $SHEEPY404_ADDRESS"

cast send $SHEEPY404_ADDRESS "setRole(address,uint256,bool)" $DEPLOYER_ADDRESS 0 true --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY
echo "Role set on Sheepy404 contract for DEPLOYER_ADDRESS"

cast send $SHEEPY404_ADDRESS "reroll(uint256[],uint256[])" "[$TOKEN_IDS]" "[$URI_IDS]" --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_2
echo "Reroll function invoked from PRIVATE_KEY_2"

cast send $SHEEPY404_ADDRESS "reroll(uint256[],uint256[])" "[$TOKEN_IDS]" "[$URI_IDS]" --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY
echo "Reroll function invoked from PRIVATE_KEY"

forge verify-contract $SHEEPY404_ADDRESS src/Sheepy404.sol:Sheepy404 --zksync --verifier etherscan --verifier-url "https://api-sepolia.abscan.org/api" --etherscan-api-key IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A
forge verify-contract $SHEEPY404MIRROR_ADDRESS src/Sheepy404Mirror.sol:Sheepy404Mirror --zksync --verifier etherscan --verifier-url "https://api-sepolia.abscan.org/api" --etherscan-api-key IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A
forge verify-contract $SHEEPYSALE_ADDRESS src/SheepySale.sol:SheepySale --zksync --verifier etherscan --verifier-url "https://api-sepolia.abscan.org/api" --etherscan-api-key IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A
forge verify-contract $MOONSHEEP_MISSION_GAME_ADDRESS src/MoonsheepMissionGame.sol:MoonsheepMissionGame --zksync --verifier etherscan --verifier-url "https://api-sepolia.abscan.org/api" --etherscan-api-key IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A --constructor-args $(cast abi-encode "constructor(address,address,address,uint256)" $SHEEPY404MIRROR_ADDRESS $SHEEPY404_ADDRESS $MISSION_REWARD_MANAGER_ADDRESS $MISSION_DURATION)
forge verify-contract $MISSION_REWARD_MANAGER_ADDRESS src/MissionRewardManager.sol:MissionRewardManager --zksync --verifier etherscan --verifier-url "https://api-sepolia.abscan.org/api" --etherscan-api-key IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A

forge verify-contract $SHEEPY404_ADDRESS src/Sheepy404.sol:Sheepy404 --zksync --verifier zksync --verifier-url "https://api-explorer-verify.testnet.abs.xyz/contract_verification"
forge verify-contract $SHEEPY404MIRROR_ADDRESS src/Sheepy404Mirror.sol:Sheepy404Mirror --zksync --verifier zksync --verifier-url "https://api-explorer-verify.testnet.abs.xyz/contract_verification"
forge verify-contract $SHEEPYSALE_ADDRESS src/SheepySale.sol:SheepySale --zksync --verifier zksync --verifier-url "https://api-explorer-verify.testnet.abs.xyz/contract_verification"
forge verify-contract $MOONSHEEP_MISSION_GAME_ADDRESS src/MoonsheepMissionGame.sol:MoonsheepMissionGame --zksync --verifier zksync --verifier-url "https://api-explorer-verify.testnet.abs.xyz/contract_verification" --constructor-args $(cast abi-encode "constructor(address,address,address,uint256)" $SHEEPY404MIRROR_ADDRESS $SHEEPY404_ADDRESS $MISSION_REWARD_MANAGER_ADDRESS $MISSION_DURATION)
forge verify-contract $MISSION_REWARD_MANAGER_ADDRESS src/MissionRewardManager.sol:MissionRewardManager --zksync --verifier zksync --verifier-url "https://api-explorer-verify.testnet.abs.xyz/contract_verification"

# Echo all deployed contract addresses
echo "Sheepy404 Contract Address: $SHEEPY404_ADDRESS"
echo "Sheepy404Mirror Contract Address: $SHEEPY404MIRROR_ADDRESS"
echo "SheepySale Contract Address: $SHEEPYSALE_ADDRESS"
echo "MissionRewardManager Contract Address: $MISSION_REWARD_MANAGER_ADDRESS"
echo "MoonsheepMissionGame Contract Address: $MOONSHEEP_MISSION_GAME_ADDRESS"

echo "Deployment completed!"