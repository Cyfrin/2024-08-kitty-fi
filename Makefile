-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil huff

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

all:  remove install build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install foundry-rs/forge-std --no-commit && forge install OpenZeppelin/openzeppelin-contracts@v5.0.2 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts --no-commit

# Update Dependencies
update:; forge update

build:; forge build --via-ir

compile:; forge compile --via-ir

test :; @forge test --via-ir --fork-url $(SEPOLIA_RPC_URL) 

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

coverage :; forge coverage --via-ir

coverage-report :; forge coverage --report debug > coverage-report.txt --via-ir

scope :; tree ./src/ | sed 's/└/#/g; s/──/--/g; s/├/#/g; s/│ /|/g; s/│/|/g'

scopefile :; @tree ./src/ | sed 's/└/#/g' | awk -F '── ' '!/\.sol$$/ { path[int((length($$0) - length($$2))/2)] = $$2; next } { p = "src"; for(i=2; i<=int((length($$0) - length($$2))/2); i++) if (path[i] != "") p = p "/" path[i]; print p "/" $$2; }' > scope.txt

slither :; slither . --config-file slither.config.json 

aderyn :; aderyn .