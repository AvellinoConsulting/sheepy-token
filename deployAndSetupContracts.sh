#!/bin/bash

# ACCOUNT PRIVATE KEYS
PRIVATE_KEY_DEPLOYER="0x5a47de970be76260b4ddea9e4e4f4c4ef6344001ebb6b52d96205ad11d7916fd"
PRIVATE_KEY_USER="0xd5da6986b8ad2a54ea62199d9b2dee21d4717a77945d073cb989fa8330cb1dd5"

# ACCOUNT ADDRESSES
DEPLOYER_ADDRESS="0x86ee94AF5aBB6E2f7073F3B2d0caecA5049F088b"
USER_ADDRESS="0x2bd80D4fFFf9C32Fb884cC87c8e4D0880381C517"
USER_ADDRESS_SHASHANK="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
TRUSTED_SIGNER=$DEPLOYER_ADDRESS
INITIAL_SHEEPY_SALE_OWNER=$DEPLOYER_ADDRESS
INITIAL_SHEEPY_SALE_ADMIN=$DEPLOYER_ADDRESS
SHEEPY_HOLDER=$DEPLOYER_ADDRESS

# RPC URL
RPC_URL="https://api.testnet.abs.xyz"

# ARGUMENTS
TOKEN_IDS="[101]"
URI_IDS="[101]"
USER_NONCE=0
REVEAL_EXPIRY=10000000000000
REVEAL_SIGNATURE=0x9f928e056233223f27a88249edd1e51de7a90b5e77f4ea8d7d0c84930a9349902c0e577d3b2b4782d3e0dba8a3d473c6b782df337b492778e7ed897ddb6655d11b
MISSION_DURATION=60
REROLL_PRICE=5000000000000000000
TOKEN_BASE_URI="https://blush-naval-wildcat-408.mypinata.cloud/ipfs/bafybeif6mrlzkjv7km5vtozyvfs5qxjpfxajrohrxlmzl5qut3ejz3yc5m/{id}.json"
UNREVEALED_TOKEN_BASE_URI="https://blush-naval-wildcat-408.mypinata.cloud/ipfs/bafybeidgkd6oxxjumxnfmmcvj727vdb5vqqbfbjl3knsgdbz2426nzpfme/{id}.json"
TOKEN_NAME="SheepyToken"
TOKEN_SYMBOL="\$SHEEP"
NOT_SO_SECRET_PHRASE="SomethingSomethingNoGrief"

# Build contracts with zkSync
forge build --zksync

# DEPLOYMENT CONTRACTS
echo "Deploying contracts..."

echo "Deploying contracts Sheepy404..."
SHEEPY404_ADDRESS=$(forge create src/Sheepy404.sol:Sheepy404 --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER | grep 'Deployed to:' | awk '{print $3}')
echo "Sheepy404 deployed to: $SHEEPY404_ADDRESS"

echo "Deploying contracts Sheepy404Mirror..."
SHEEPY404MIRROR_ADDRESS=$(forge create src/Sheepy404Mirror.sol:Sheepy404Mirror --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER | grep 'Deployed to:' | awk '{print $3}')
echo "Sheepy404Mirror deployed to: $SHEEPY404MIRROR_ADDRESS"

echo "Deploying contracts SheepySale..."
SHEEPYSALE_ADDRESS=$(forge create src/SheepySale.sol:SheepySale --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER | grep 'Deployed to:' | awk '{print $3}')
echo "SheepySale deployed to: $SHEEPYSALE_ADDRESS"

echo "Deploying contracts MissionRewardManager..."
MISSION_REWARD_MANAGER_ADDRESS=$(forge create src/MissionRewardManager.sol:MissionRewardManager --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER | grep 'Deployed to:' | awk '{print $3}')
echo "MissionRewardManager deployed to: $MISSION_REWARD_MANAGER_ADDRESS"

echo "Deploying contracts MoonsheepMissionGame..."
MOONSHEEP_MISSION_GAME_ADDRESS=$(forge create src/MoonsheepMissionGame.sol:MoonsheepMissionGame --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER --constructor-args $SHEEPY404MIRROR_ADDRESS $SHEEPY404_ADDRESS $MISSION_REWARD_MANAGER_ADDRESS $MISSION_DURATION| grep 'Deployed to:' | awk '{print $3}')
echo "MoonsheepMissionGame deployed to: $MOONSHEEP_MISSION_GAME_ADDRESS"


# SETUP CONTRACTS
echo "Setting up contracts..."


echo "Setting up Sheepy404..."
# Initialize Sheepy404 contract
cast send $SHEEPY404_ADDRESS "initialize(address,address,address,string)" $DEPLOYER_ADDRESS $DEPLOYER_ADDRESS $SHEEPY404MIRROR_ADDRESS $NOT_SO_SECRET_PHRASE --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER

# Setting Name and Symbol
cast send $SHEEPY404_ADDRESS "setNameAndSymbol(string,string)" $TOKEN_NAME $TOKEN_SYMBOL --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER

# Setting Base URI
cast send $SHEEPY404_ADDRESS "setBaseURI(string)" $TOKEN_BASE_URI --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER

# Setting Reroll Price
cast send $SHEEPY404_ADDRESS "setRerollPrice(uint256)" $REROLL_PRICE --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER

# Setting Fee Collector
cast send $SHEEPY404_ADDRESS "setFeeCollector(address)" $DEPLOYER_ADDRESS --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER

# Setting Unrevealed Base URI
cast send $SHEEPY404_ADDRESS "setUnrevealedBaseUri(string)" $UNREVEALED_TOKEN_BASE_URI --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER

# Setting up trusted signer
cast send $SHEEPY404_ADDRESS "setTrustedSigner(address)" $TRUSTED_SIGNER --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER

echo "Setting up SheepySale contract"
# Initialize SheepySale contract
cast send $SHEEPYSALE_ADDRESS "initialize(address,address,string)" $INITIAL_SHEEPY_SALE_OWNER $INITIAL_SHEEPY_SALE_ADMIN $NOT_SO_SECRET_PHRASE --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER

echo "Setting up MoonsheepMissionGame contract"

# Set DEPLOYER_ADDRESS as sheepyHolder in MoonsheepMissionGame
cast send $MOONSHEEP_MISSION_GAME_ADDRESS "setSheepyHolder(address)" $SHEEPY_HOLDER --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER
echo "Set $SHEEPY_HOLDER as sheepyHolder in MoonsheepMissionGame"

echo "$SYMBOL transfers" 

# transfer $SHEEP to $USER_ADDRESS_SHASHANK
cast send $SHEEPY404_ADDRESS "transfer(address,uint256)" $USER_ADDRESS_SHASHANK 10090000000000000000000000 --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER
echo "Successfully transferred tokens from $DEPLOYER_ADDRESS to $USER_ADDRESS_SHASHANK"

# transfer $SHEEP to $USER_ADDRESS
cast send $SHEEPY404_ADDRESS "transfer(address,uint256)" $USER_ADDRESS 1090000000000000000000000 --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER
echo "Successfully transferred tokens from $DEPLOYER_ADDRESS to $USER_ADDRESS"

# Approve MoonsheepMissionGame contract to spend Sheepy404 tokens
cast send $SHEEPY404_ADDRESS "approve(address,uint256)" $MOONSHEEP_MISSION_GAME_ADDRESS 99999000000000000000000 --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_DEPLOYER
echo "Successfully approved $MOONSHEEP_MISSION_GAME_ADDRESS to spend tokens from $SHEEPY404_ADDRESS"

# Verify Reveal
cast send $SHEEPY404_ADDRESS "reveal(uint256[],uint256[],uint256,uint256,bytes)" $TOKEN_IDS $URI_IDS $USER_NONCE $REVEAL_EXPIRY $REVEAL_SIGNATURE --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_USER


# Verify Start Mission

cast send $SHEEPY404MIRROR_ADDRESS "approve(address,uint256)" $MOONSHEEP_MISSION_GAME_ADDRESS 101 --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_USER
echo "Successfully approved $MOONSHEEP_MISSION_GAME_ADDRESS to spend tokens from $SHEEPY404MIRROR_ADDRESS"

cast send $MOONSHEEP_MISSION_GAME_ADDRESS "startMission(uint256)" 101 --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_USER
echo "Successfully started mission"

sleep 120

# Verify End Mission
cast send $MOONSHEEP_MISSION_GAME_ADDRESS "completeMission(uint256)" 101 --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY_USER
echo "Successfully completed mission"

echo "Verifying contracts..."
# Verify contracts on etherscan
forge verify-contract $SHEEPY404_ADDRESS src/Sheepy404.sol:Sheepy404 --zksync --verifier etherscan --verifier-url "https://api-sepolia.abscan.org/api" --etherscan-api-key IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A
forge verify-contract $SHEEPY404MIRROR_ADDRESS src/Sheepy404Mirror.sol:Sheepy404Mirror --zksync --verifier etherscan --verifier-url "https://api-sepolia.abscan.org/api" --etherscan-api-key IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A
forge verify-contract $SHEEPYSALE_ADDRESS src/SheepySale.sol:SheepySale --zksync --verifier etherscan --verifier-url "https://api-sepolia.abscan.org/api" --etherscan-api-key IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A
forge verify-contract $MOONSHEEP_MISSION_GAME_ADDRESS src/MoonsheepMissionGame.sol:MoonsheepMissionGame --zksync --verifier etherscan --verifier-url "https://api-sepolia.abscan.org/api" --etherscan-api-key IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A --constructor-args $(cast abi-encode "constructor(address,address,address,uint256)" $SHEEPY404MIRROR_ADDRESS $SHEEPY404_ADDRESS $MISSION_REWARD_MANAGER_ADDRESS $MISSION_DURATION)
forge verify-contract $MISSION_REWARD_MANAGER_ADDRESS src/MissionRewardManager.sol:MissionRewardManager --zksync --verifier etherscan --verifier-url "https://api-sepolia.abscan.org/api" --etherscan-api-key IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A

# Verify contracts on zkSync
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

# Sheepy404 deployed to: 0x85981fdcF4903767eCCaeb530f330e30421E083c
# Sheepy404Mirror deployed to: 0x5FdA394D755100c2449Fb3e62276B7F7f03df1a6
# SheepySale deployed to: 0x89A38F28716415eA658d45D63664696Ad5098cB8
# MissionRewardManager deployed to: 0x8279c360f2daeD1C7F5ba67a4211cCC2CC25ee6B
# MoonsheepMissionGame deployed to: 0x09Ea8A373f45B3aD8189b497c2FbaAbAfaf5f3DA