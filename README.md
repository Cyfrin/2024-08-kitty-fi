# First Flight #?: KittyFi

# Contest Details

### Prize Pool

- High - 100xp
- Medium - 20xp
- Low - 2xp

- Starts: August 01, 2024 Noon UTC
- Ends: August 08, 2024 Noon UTC

### Stats

- nSLOC: 224
- Complexity Score: 203

[//]: # (contest-details-open)

# Disclaimer

_This code was created for Codehawks as a first flight. It is made with bugs and flaws on purpose._
_Don't use any part of this code without reviewing it and audit it._

# About
KittyFi, a EUR pegged stablecoin based protocol which proactively maintains the user's deposited collateral to earn yield on it via Aave protocol. <br>
With KittyFi, the collateral deposited by user will not just remain in there for backing the KittyCoin but will earn yield on it via Aave protocol. <br>
By utilizing the interest earned on collateral, the protocol will reduce the risk of user getting liquidated by equally allocating the interest earned on collateral to every user in the pool.

### KittyCoin
The stable coin of KittyFi protocol which is pegged to EUR and can be minted by supplying collateral and minting via KittyPool.

### KittyPool
This smart contract is assigned the role to allow user to deposit collateral and mint KittyCoin from it. The KittyPool contract routes the call to the respective vault for deposit and withdrawal fo collateral which is created for every collateral token used in protocol. <br>
The user is required to main overcollateralization in order to prevent liquidation of their pawsition (I mean position (meows, purrss)). <br>
The pool also handles liquidations, the user gets some percentage reward on the collateral liquidated from the user's vault.

### KittyVault
Every collateral token have their own vault deployed via `KittyPool` contract.
The vault is responsible for maintaining the collateral deposited by user and supply it to Aave protocol to earn yield on it.
The KittyVault when queried with the amount of collateral present in it or collateral of user, then it will return the interest earned total collateral.

### Actors
- `User` - Performing deposit and withdrawal of collateral along with minting and burning of KittyCoin
- `Meowntainer` - Responsible for performing executions to supply and withdraw collateral from Aave protocol on KittyVault

[//]: # (contest-details-close)

[//]: # (getting-started-open)

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

## Installation

1. Clone the repository and compile contracts
```bash 
git clone https://github.com/cyfrin/2024-08-kitty-fi
code 2024-08-kitty-fi
make
```

## Build

```
make build
```

## Test

```
make test
```

## Note

As custom errors are used in require statements, therefore don't forgot to use `--via-ir` flag in command

[//]: # (getting-started-close)

[//]: # (scope-open)

# Audit Scope Details

- In Scope:
```
src/KittyCoin.sol
src/KittyPool.sol
src/KittyVault.sol
```

## Compatibilities

- Solc Version: `0.8.26`
- Chain(s) to deploy contract to:
  - Ethereum
  - Polygon
  - Avalanche
- Tokens that can be used as collateral: All tokens avaiable for lending on Aave pool on respective chains except for Fee on Transfer tokens and Rebasing tokens.

[//]: # (scope-close)

[//]: # (known-issues-open)

# Known Issues and Assumptions

- Trusted roles - Meowntainer (You trust your cat, then you have to trust Meowntainer, purrrr)
- The `vaults` array used in KittyPool will not have a length more than 20, that means that are at most 20 collateral tokens that will be used in protocol.

[//]: # (known-issues-close)
