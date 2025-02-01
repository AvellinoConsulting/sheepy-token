## Requirements

ZKsync Foundry.

https://foundry-book.zksync.io/

## Setup

There are three deployed contracts, and you'll need to setup those with `initialize` functions.

- Sheepy404 (the ERC20)


```solidity
function initialize(
    address initialOwner,
    address initialAdmin,
    string memory name_,
    string memory symbol_,
    address _initialDeployer,
    string memory notSoSecret
)
```

- Sheepy404Mirror (the ERC721 counterpart)

```solidity
constructor(address _initialDeployer) DN404Mirror(_initialDeployer) {}
```

- SheepySale (the Sale contract)


```solidity
function initialize(
    address initialOwner,
    address initialAdmin,
    string memory notSoSecret
)
```

Here, `notSoSecret` is `SomethingSomethingNoGrief`.
