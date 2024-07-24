// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import { KittyPool } from "src/KittyPool.sol";
import { KittyCoin } from "src/KittyCoin.sol";
import { KittyVault } from "src/KittyVault.sol";
import { Script } from "forge-std/Script.sol";
import { HelperConfig } from "./HelperConfig.s.sol";

contract DeployKittyFi is Script {
    function run() external returns (KittyPool, KittyCoin, KittyVault) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getNetworkConfig();

        vm.startBroadcast();
        KittyPool kittyPool = new KittyPool(msg.sender, config.euroPriceFeed, config.aavePool);
        kittyPool.meownufactureKittyVault(config.weth, config.ethUsdPriceFeed);
        vm.stopBroadcast();

        KittyCoin kittyCoin = KittyCoin(kittyPool.getKittyCoin());
        KittyVault wethVault = KittyVault(kittyPool.getTokenToVault(config.weth));

        return (kittyPool, kittyCoin, wethVault);
    }
}