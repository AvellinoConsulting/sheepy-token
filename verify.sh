forge verify-contract 0x24f715C6B2DB3BfD3F5e633A7ACD5D14E4CDA03F src/Sheepy404.sol:Sheepy404 --zksync --verifier etherscan --verifier-url "https://api-sepolia.abscan.org/api" --etherscan-api-key IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A
forge verify-contract 0x81932962ec3bc941f99FCb39F599F0e36420506D src/Sheepy404Mirror.sol:Sheepy404Mirror --zksync --verifier etherscan --verifier-url "https://api-sepolia.abscan.org/api" --etherscan-api-key IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A
forge verify-contract 0x2FCf3582C5Fe3f5DD238163527Aa8E028F1fD61d src/SheepySale.sol:SheepySale --zksync --verifier etherscan --verifier-url "https://api-sepolia.abscan.org/api" --etherscan-api-key IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A
forge verify-contract 0x20B95907917955F8467418a07b0Ebb3A8AaeEF15 src/MoonsheepMissionGame.sol:MoonsheepMissionGame --zksync --verifier etherscan --verifier-url "https://api-sepolia.abscan.org/api" --etherscan-api-key IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A --constructor-args $(cast abi-encode "constructor(address,address,address,uint256)" 0x81932962ec3bc941f99FCb39F599F0e36420506D 0x24f715C6B2DB3BfD3F5e633A7ACD5D14E4CDA03F 0xd894325a25230CF53C0e7b5Dbb2bd109d97AB566 60)
forge verify-contract 0xd894325a25230CF53C0e7b5Dbb2bd109d97AB566 src/MissionRewardManager.sol:MissionRewardManager --zksync --verifier etherscan --verifier-url "https://api-sepolia.abscan.org/api" --etherscan-api-key IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A

forge verify-contract 0x24f715C6B2DB3BfD3F5e633A7ACD5D14E4CDA03F src/Sheepy404.sol:Sheepy404 --zksync --verifier zksync --verifier-url "https://api-explorer-verify.testnet.abs.xyz/contract_verification"
forge verify-contract 0x81932962ec3bc941f99FCb39F599F0e36420506D src/Sheepy404Mirror.sol:Sheepy404Mirror --zksync --verifier zksync --verifier-url "https://api-explorer-verify.testnet.abs.xyz/contract_verification"
forge verify-contract 0x2FCf3582C5Fe3f5DD238163527Aa8E028F1fD61d src/SheepySale.sol:SheepySale --zksync --verifier zksync --verifier-url "https://api-explorer-verify.testnet.abs.xyz/contract_verification"
forge verify-contract 0x20B95907917955F8467418a07b0Ebb3A8AaeEF15 src/MoonsheepMissionGame.sol:MoonsheepMissionGame --zksync --verifier zksync --verifier-url "https://api-explorer-verify.testnet.abs.xyz/contract_verification" --constructor-args $(cast abi-encode "constructor(address,address,address,uint256)" 0x81932962ec3bc941f99FCb39F599F0e36420506D 0x24f715C6B2DB3BfD3F5e633A7ACD5D14E4CDA03F 0xd894325a25230CF53C0e7b5Dbb2bd109d97AB566 60)
forge verify-contract 0xd894325a25230CF53C0e7b5Dbb2bd109d97AB566 src/MissionRewardManager.sol:MissionRewardManager --zksync --verifier zksync --verifier-url "https://api-explorer-verify.testnet.abs.xyz/contract_verification"

# Sheepy404 Contract Address: 0x24f715C6B2DB3BfD3F5e633A7ACD5D14E4CDA03F
# Sheepy404Mirror Contract Address: 0x81932962ec3bc941f99FCb39F599F0e36420506D
# SheepySale Contract Address: 0x2FCf3582C5Fe3f5DD238163527Aa8E028F1fD61d
# MissionRewardManager Contract Address: 0xd894325a25230CF53C0e7b5Dbb2bd109d97AB566
# MoonsheepMissionGame Contract Address: 0x20B95907917955F8467418a07b0Ebb3A8AaeEF15