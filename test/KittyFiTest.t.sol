// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import { Test, console } from "forge-std/Test.sol";
import { KittyCoin } from "src/KittyCoin.sol";
import { KittyPool } from "src/KittyPool.sol";
import { KittyVault, IAavePool } from "src/KittyVault.sol";
import { DeployKittyFi, HelperConfig } from "script/DeployKittyFi.s.sol";
import { ERC20Mock } from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import { MockV3Aggregator } from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract KittyFiTest is Test {
    KittyCoin kittyCoin;
    KittyPool kittyPool;
    KittyVault wethVault;
    HelperConfig.NetworkConfig config;
    address weth;
    address meowntainer = makeAddr("meowntainer");
    address user = makeAddr("user");
    uint256 AMOUNT = 10e18;

    function setUp() external {
        HelperConfig helperConfig = new HelperConfig();
        config = helperConfig.getNetworkConfig();
        weth = config.weth;
        deal(weth, user, AMOUNT);

        kittyPool = new KittyPool(meowntainer, config.euroPriceFeed, config.aavePool);

        vm.prank(meowntainer);
        kittyPool.meownufactureKittyVault(config.weth, config.ethUsdPriceFeed);

        kittyCoin = KittyCoin(kittyPool.getKittyCoin());
        wethVault = KittyVault(kittyPool.getTokenToVault(config.weth));
    }

    function testConstructorValuesSetUpCorrectly() public view {
        assertEq(address(kittyPool.getMeowntainer()), meowntainer);
        assertEq(address(kittyPool.getKittyCoin()), address(kittyCoin));
        assertEq(address(kittyPool.getTokenToVault(weth)), address(wethVault));
        assertEq(address(kittyPool.getAavePool()), config.aavePool);
    }

    function test_OnlyMeowntainCanAddNewToken() public {
        address attacker = makeAddr("attacker");

        vm.startPrank(attacker);
        ERC20Mock token = new ERC20Mock();
        MockV3Aggregator priceFeed = new MockV3Aggregator(8, 1e8);

        vm.expectRevert(abi.encodeWithSelector(KittyPool.KittyPool__NotMeowntainerPurrrrr.selector));
        kittyPool.meownufactureKittyVault(address(token), address(priceFeed));
        vm.stopPrank();
    }

    function test_MeowntainerAddingTokenSetUpCorrectly() public {
        // initially there is no vault for wbtc
        require(kittyPool.getTokenToVault(config.wbtc) == address(0));

        vm.prank(meowntainer);
        kittyPool.meownufactureKittyVault(config.wbtc, config.btcUsdPriceFeed);

        address vaultCreated = kittyPool.getTokenToVault(config.wbtc);

        require(vaultCreated != address(0), "Vault not created");

        KittyVault _vault = KittyVault(vaultCreated);

        assert(_vault.i_token() == config.wbtc);
        assert(_vault.i_pool() == address(kittyPool));
        assert(address(_vault.i_priceFeed()) == config.btcUsdPriceFeed);
        assert(address(_vault.i_euroPriceFeed()) == config.euroPriceFeed);
        assert(address(_vault.i_aavePool()) == config.aavePool);
        assert(_vault.meowntainer() == meowntainer);
        assert(address(_vault.i_aavePool()) == config.aavePool);
    }

    function test_UserDepositsInVault() public {
        uint256 toDeposit = 5 ether;

        vm.startPrank(user);

        IERC20(weth).approve(address(wethVault), toDeposit);
        kittyPool.depawsitMeowllateral(weth, toDeposit);

        vm.stopPrank();

        assertEq(wethVault.totalMeowllateralInVault(), toDeposit);
        assertEq(wethVault.totalCattyNip(), toDeposit);
        assertEq(wethVault.userToCattyNip(user), toDeposit);
        assertEq(IERC20(weth).balanceOf(address(wethVault)), toDeposit);
    }

    function test_UserDepositsAndMintsKittyCoin() public {
        uint256 toDeposit = 5 ether;
        uint256 amountToMint = 20e18;       // 20 KittyCoin

        vm.startPrank(user);

        IERC20(weth).approve(address(wethVault), toDeposit);
        kittyPool.depawsitMeowllateral(weth, toDeposit);

        kittyPool.meowintKittyCoin(amountToMint);

        vm.stopPrank();

        assertEq(kittyPool.getKittyCoinMeownted(user), amountToMint);
    }

    function test_UserWithdrawCollateral() public {
        uint256 toDeposit = 5 ether;

        vm.startPrank(user);

        IERC20(weth).approve(address(wethVault), toDeposit);
        kittyPool.depawsitMeowllateral(weth, toDeposit);

        vm.stopPrank();


        // now user wants to withdraw 
        uint256 toWithdraw = 3 ether;

        vm.startPrank(user);

        kittyPool.whiskdrawMeowllateral(weth, toWithdraw);

        vm.stopPrank();

        assertEq(wethVault.totalMeowllateralInVault(), toDeposit - toWithdraw);
        assertEq(wethVault.totalCattyNip(), toDeposit - toWithdraw);
        assertEq(wethVault.userToCattyNip(user), toDeposit - toWithdraw);
        assertEq(IERC20(weth).balanceOf(address(wethVault)), toDeposit - toWithdraw);

        assertEq(IERC20(weth).balanceOf(user), AMOUNT - toDeposit + toWithdraw);
    }

    function test_BurningKittyCoin() public {
        uint256 toDeposit = 5 ether;
        uint256 amountToMint = 20e18;       // 20 KittyCoin

        vm.startPrank(user);

        IERC20(weth).approve(address(wethVault), toDeposit);
        kittyPool.depawsitMeowllateral(weth, toDeposit);

        kittyPool.meowintKittyCoin(amountToMint);

        vm.stopPrank();

        // user burns 15 KittyCoin
        uint256 toBurn = 15e18;

        vm.prank(user);
        kittyPool.burnKittyCoin(user, toBurn);

        assert(kittyPool.getKittyCoinMeownted(user) == amountToMint - toBurn);
    }

    modifier userDepositsCollateral() {
        uint256 toDeposit = 5 ether;
        vm.startPrank(user);
        IERC20(weth).approve(address(wethVault), toDeposit);
        kittyPool.depawsitMeowllateral(weth, toDeposit);
        vm.stopPrank();
        _;
    }

    function test_supplyingCollateralToAave() public userDepositsCollateral {
        uint256 totalDepositedInVault = 5 ether;

        // meowntainer transfers collateral in eth vault to Aave to earn interest
        uint256 toSupply = 3 ether;

        vm.prank(meowntainer);
        wethVault.purrrCollateralToAave(toSupply);

        assertEq(wethVault.totalMeowllateralInVault(), totalDepositedInVault - toSupply);

        uint256 totalCollateralBase = wethVault.getTotalMeowllateralInAave();

        assert(totalCollateralBase > 0);
    }

    function test_supplyAndWithdrawCollateralFromAave() public userDepositsCollateral {
        uint256 totalDepositedInVault = 5 ether;

        // meowntainer transfers collateral in eth vault to Aave to earn interest
        uint256 toSupply = 3 ether;

        vm.prank(meowntainer);
        wethVault.purrrCollateralToAave(toSupply);

        // now withdrawing whole collateral deposited

        vm.prank(meowntainer);
        wethVault.purrrCollateralFromAave(toSupply);

        assertEq(wethVault.totalMeowllateralInVault(), totalDepositedInVault);

        assert(wethVault.getTotalMeowllateralInAave() == 0);
    }
}