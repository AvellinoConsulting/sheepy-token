#!/bin/bash

# Set your environment variables
RPC_URL="https://api.testnet.abs.xyz"
PRIVATE_KEY="0x5a47de970be76260b4ddea9e4e4f4c4ef6344001ebb6b52d96205ad11d7916fd"

# Initialize deployer address
DEPLOYER_ADDRESS="0x86ee94AF5aBB6E2f7073F3B2d0caecA5049F088b"
echo "Deployer address: $DEPLOYER_ADDRESS"

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
cast send $SHEEPY404_ADDRESS "setBaseURI(string)" "https://blush-naval-wildcat-408.mypinata.cloud/ipfs/bafybeiav3gfyyzygjtqcfc42druepoty3tdw45gaahq3m5igwdkgcen7eq/{id}.json" --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Set name and symbol on Sheepy404 contract
cast send $SHEEPY404_ADDRESS "setNameAndSymbol(string,string)" "SheepyToken" "$SHEEP" --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# transfer $SHEEP to $SHEEPYSALE_ADDRESS
cast send $SHEEPY404_ADDRESS "transfer(address,uint256)" "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" 1090000000000000000000000 --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# transfer $SHEEP to $SHEEPYSALE_ADDRESS
cast send $SHEEPY404_ADDRESS "transfer(address,uint256)" "0x2bd80D4fFFf9C32Fb884cC87c8e4D0880381C517" 1090000000000000000000000 --zksync --rpc-url $RPC_URL --private-key $PRIVATE_KEY

echo "Deployment completed!"
