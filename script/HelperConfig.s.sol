// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import { Script } from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address aavePool;
        address euroPriceFeed;
        address ethUsdPriceFeed;
        address btcUsdPriceFeed;
        address usdcUsdPriceFeed;
        address weth;
        address wbtc;
        address usdc;
    }

    NetworkConfig private networkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            networkConfig = getSepoliaConfig();
        }
    }

    function getSepoliaConfig() internal pure returns (NetworkConfig memory) {
        return NetworkConfig ({
            aavePool: 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951,
            euroPriceFeed: 0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910,
            ethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            btcUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            usdcUsdPriceFeed: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E,
            weth: 0xC558DBdd856501FCd9aaF1E62eae57A9F0629a3c,
            wbtc: 0x29f2D40B0605204364af54EC677bD022dA425d03,
            usdc: 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8
        });
    }

    function getNetworkConfig() external view returns (NetworkConfig memory) {
        return networkConfig;
    }
}