// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import { ERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IKittyVault } from "./interfaces/IKittyVault.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { IAavePool } from "./interfaces/IAavePool.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

contract KittyVault {
    using SafeERC20 for IERC20;
    using Math for uint256;

    error KittyVault__NotPool();
    error KittyVault__NotMeowntainerPurrrrr();

    address public immutable i_token;
    address public immutable i_pool;
    AggregatorV3Interface public immutable i_priceFeed;
    AggregatorV3Interface public immutable i_euroPriceFeed;
    address public meowntainer;
    IAavePool public immutable i_aavePool;
    uint256 public totalMeowllateralInVault;

    /// @notice holds the user's shares of collateral (proportion)
    /// @dev cattyNip cattyNip I want a mouse, catch me a mouse as fast as I meow
    mapping(address user => uint256 cattyNip) public userToCattyNip;
    uint256 public totalCattyNip;

    uint256 private constant EXTRA_DECIMALS = 1e10;
    uint256 private constant PRECISION = 1e18;

    modifier onlyMeowntainer {
        require(msg.sender == meowntainer, KittyVault__NotMeowntainerPurrrrr());
        _;
    }

    modifier onlyPool() {
        require(msg.sender == i_pool, KittyVault__NotPool());
        _;
    }

    /**
     * 
     * @param _token the collateral token of this vault
     * @param _pool The KittyPool address
     * @param _priceFeed Price feed for the collateral token of vault
     * @param _euroPriceFeed Price feed for euro
     * @param _meowntainer The maintainer of the executions related to Aave supply and withdraw
     * @param _aavePool The aave pool address on which collateral is supplied to yield interest
     */
    constructor(address _token, address _pool, address _priceFeed, address _euroPriceFeed, address _meowntainer, address _aavePool) {
        i_token = _token;
        i_pool = _pool;
        i_priceFeed = AggregatorV3Interface(_priceFeed);
        i_euroPriceFeed = AggregatorV3Interface(_euroPriceFeed);
        meowntainer = _meowntainer;
        i_aavePool = IAavePool(_aavePool);
    }

    /**
     * @param _user The user who wants to deposit collateral
     * @param _ameownt The amount of collateral to deposit
     */
    function executeDepawsit(address _user, uint256 _ameownt) external onlyPool {
        uint256 _totalMeowllateral = getTotalMeowllateral();
        uint256 _cattyNipGenerated;

        if (_totalMeowllateral == 0) {
            _cattyNipGenerated = _ameownt;
        }
        else {
            _cattyNipGenerated = _ameownt.mulDiv(totalCattyNip, _totalMeowllateral);
        }

        userToCattyNip[_user] += _cattyNipGenerated;
        totalCattyNip += _cattyNipGenerated;
        totalMeowllateralInVault += _ameownt;

        IERC20(i_token).safeTransferFrom(_user, address(this), _ameownt);
    }

    /**
     * @param _user The user who wants to withdraw collateral
     * @param _cattyNipToWithdraw The amount of shares corresponding to collateral to withdraw
     */
    function executeWhiskdrawal(address _user, uint256 _cattyNipToWithdraw) external onlyPool {
        uint256 _ameownt = _cattyNipToWithdraw.mulDiv(getTotalMeowllateral(), totalCattyNip);
        userToCattyNip[_user] -= _cattyNipToWithdraw;
        totalCattyNip -= _cattyNipToWithdraw;
        totalMeowllateralInVault -= _ameownt;

        IERC20(i_token).safeTransfer(_user, _ameownt);
    }


    ////////////////////////////////////////////
    ////////// AAVE SUPPLY FOR INTEREST ////////
    //////////////////////////////////////////// 
    
    /**
     * @notice Supplies collateral to Aave pool to earn interest
     * @param _ameowntToSupply The amount of collateral to supply to Aave
     */
    function purrrCollateralToAave(uint256 _ameowntToSupply) external onlyMeowntainer {
        totalMeowllateralInVault -= _ameowntToSupply;
        IERC20(i_token).approve(address(i_aavePool), _ameowntToSupply);
        i_aavePool.supply( { asset: i_token, amount: _ameowntToSupply, onBehalfOf: address(this), referralCode: 0 } );
    }

    /**
     * @notice Withdraws collateral from Aave pool
     * @param _ameowntToWhiskdraw The amount of collateral to withdraw from Aave
     */
    function purrrCollateralFromAave(uint256 _ameowntToWhiskdraw) external onlyMeowntainer {
        totalMeowllateralInVault += _ameowntToWhiskdraw;
        i_aavePool.withdraw( { asset: i_token, amount: _ameowntToWhiskdraw, to: address(this) } );
    }

    /**
     * @notice Gets the user's collateral for this vault in euros
     * @param _user The user for which the collateral is calculated
     */
    function getUserVaultMeowllateralInEuros(address _user) external view returns (uint256) {
        (, int256 collateralToUsdPrice, , , ) = i_priceFeed.latestRoundData();
        (, int256 euroPriceFeedAns, , ,) = i_euroPriceFeed.latestRoundData();
        uint256 collateralAns = getUserMeowllateral(_user).mulDiv(uint256(collateralToUsdPrice) * EXTRA_DECIMALS, PRECISION);
        return collateralAns.mulDiv(uint256(euroPriceFeedAns) * EXTRA_DECIMALS, PRECISION);
    }

    /**
     * @notice Gets the user's collateral deposited
     * @param _user The user for which the collateral is calculated
     */
    function getUserMeowllateral(address _user) public view returns (uint256) {
        uint256 totalMeowllateralOfVault = getTotalMeowllateral();
        return userToCattyNip[_user].mulDiv(totalMeowllateralOfVault, totalCattyNip);
    }

    /**
     * @notice Gets the total collateral in the vault and on aave
     */
    function getTotalMeowllateral() public view returns (uint256) {
        return totalMeowllateralInVault + getTotalMeowllateralInAave();
    }

    /**
     * @notice Gets the total sum of collateral deposited in Aave and the collateral earned by interest from Aave
     */
    function getTotalMeowllateralInAave() public view returns (uint256) {
        (uint256 totalCollateralBase, , , , , ) = i_aavePool.getUserAccountData(address(this));

        (, int256 collateralToUsdPrice, , , ) = i_priceFeed.latestRoundData();
        return totalCollateralBase.mulDiv(PRECISION, uint256(collateralToUsdPrice) * EXTRA_DECIMALS);
    }
}