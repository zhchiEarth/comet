// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';
import '../../contracts/Comet.sol';
import '../../contracts/CometExt.sol';
import '../../contracts/CometConfiguration.sol';
import '../../contracts/liquidator/OnChainLiquidator.sol';
import '../../contracts/test/SimplePriceFeed.sol';
import '../../contracts/test/FaucetToken.sol';
import '../../contracts/test/FaucetWETH.sol';

contract CompoundTest is Test {
    Comet public comet;
    // OnChainLiquidator public liquidator;

    address public alice = address(0xa);
    address public bob = address(0xb);
    address public governor = address(88);
    address public pauseGuardian = address(99);

    // contracts
    address public constant BALANCER_VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    // address public constant COMET_EXT = 0x285617313887d43256F852cAE0Ee4de4b68D45B0;
    address public constant GNOSIS_SAFE = 0xbbf3f1421D886E9b2c5D716B5192aC998af2012c;
    address public constant SUSHISWAP_ROUTER = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address public constant TIMELOCK = 0x6d903f6003cca6255D85CcA4D3B5E5146dC33925;
    address public constant UNISWAP_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public constant UNISWAP_V3_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

    // assets
    // address public constant CB_ETH = 0xFA11D91e74fdD98F79E01582B9664143E1036931;
    // address public constant ST_ETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    // address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // address public constant WST_ETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;

    // whales
    // address public constant CB_ETH_WHALE = 0xFA11D91e74fdD98F79E01582B9664143E1036931;
    // address public constant WST_ETH_WHALE = 0x10CD5fbe1b404B7E19Ef964B63939907bdaf42E2;

    FaucetWETH WETH9;
    FaucetToken CB_ETH;
    FaucetToken WST_ETH;
    CometExt COMET_EXT;

    function setUp() public {
        // XXX replace with deployed feeds after mainnet/WETH launch
        CometConfiguration.ExtConfiguration memory extConfig = CometConfiguration.ExtConfiguration({
            name32: 'Compound WETH',
            symbol32: 'cWETHv3'
        });
        COMET_EXT = new CometExt(extConfig);

        WETH9 = new FaucetWETH(1000000000001e18, 'WETH', 18, 'WETH');
        CB_ETH = new FaucetToken(1000000000001e18, 'CB_ETH', 18, 'CB_ETH');
        WST_ETH = new FaucetToken(1000000000001e18, 'WST_ETH', 18, 'WST_ETH');

        SimplePriceFeed wethPriceFeed = new SimplePriceFeed(1e8, 8);
        SimplePriceFeed wstEthPriceFeed = new SimplePriceFeed(98973832, 8);
        SimplePriceFeed cbEthPriceFeed = new SimplePriceFeed(98104218, 8);

        CometConfiguration.AssetConfig[] memory assetConfigs = new CometConfiguration.AssetConfig[](
            2
        );
        assetConfigs[0] = CometConfiguration.AssetConfig({
            asset: address(CB_ETH),
            priceFeed: address(cbEthPriceFeed),
            decimals: 18,
            borrowCollateralFactor: 9e17,
            liquidateCollateralFactor: 93e16,
            liquidationFactor: 95e16,
            supplyCap: 1000e18
        });
        assetConfigs[1] = CometConfiguration.AssetConfig({
            asset: address(WST_ETH),
            priceFeed: address(wstEthPriceFeed),
            decimals: 18,
            borrowCollateralFactor: 9e17,
            liquidateCollateralFactor: 93e16,
            liquidationFactor: 95e16,
            supplyCap: 0
        });

        comet = new Comet(
            CometConfiguration.Configuration({
                governor: governor,
                pauseGuardian: pauseGuardian,
                baseToken: address(WETH9),
                baseTokenPriceFeed: address(wethPriceFeed),
                extensionDelegate: address(COMET_EXT),
                supplyKink: 8e17,
                supplyPerYearInterestRateSlopeLow: 3e16,
                supplyPerYearInterestRateSlopeHigh: 4e17,
                supplyPerYearInterestRateBase: 0,
                borrowKink: 8e17,
                borrowPerYearInterestRateSlopeLow: 3e16,
                borrowPerYearInterestRateSlopeHigh: 2e17,
                borrowPerYearInterestRateBase: 1e16,
                storeFrontPriceFactor: 5e17,
                trackingIndexScale: 1e15,
                baseTrackingSupplySpeed: 0,
                baseTrackingBorrowSpeed: 0,
                baseMinForRewards: 1000000e6,
                baseBorrowMin: 100e6,
                targetReserves: 5000000e6,
                assetConfigs: assetConfigs
            })
        );

        comet.initializeStorage();

        // contracts
        vm.label(UNISWAP_V3_FACTORY, 'UniswapV3 Factory');

        vm.label(TIMELOCK, 'Timelock');
        vm.label(GNOSIS_SAFE, 'Gnosis Safe');
        vm.label(address(COMET_EXT), 'Comet Ext');

        // assets
        vm.label(address(CB_ETH), 'CB_ETH');
        // vm.label(address(ST_ETH), 'ST_ETH');
        // vm.label(USDC, 'USDC');
        vm.label(address(WETH9), 'WETH9');
        vm.label(address(WST_ETH), 'WST_ETH');

        // whales
        // vm.label(CB_ETH_WHALE, 'CB_ETH_WHALE');
        // vm.label(WST_ETH_WHALE, 'WST_ETH_WHALE');
    }

    function testExample() public {
        //vm.warp(1000);
        WETH9.allocateTo(address(this), 100e18);
        WETH9.approve(address(comet), 100e18);
        comet.supply(address(WETH9), 100e18);

        vm.startPrank(bob);
        WETH9.allocateTo(bob, 200e18);
        WETH9.approve(address(comet), 200e18);
        comet.supply(address(WETH9), 200e18);
        vm.stopPrank();

        CB_ETH.allocateTo(alice, 100e18);
        vm.startPrank(alice);
        CB_ETH.approve(address(comet), 100e18);
        comet.supply(address(CB_ETH), 100e18);

        console2.log('isBorrowCollateralized', comet.isBorrowCollateralized(alice));

        comet.withdraw(address(WETH9), 80e18);
        vm.stopPrank();

        vm.warp(block.timestamp + 100);
        // comet.baseSupplyIndex();
        // comet.baseBorrowIndex();
        // comet.supplyPerSecondInterestRateBase();
        // uint256 utilization = comet.getUtilization1();
        // // │   ├─ emit borrowRateEvent(supplyPerSecondInterestRateBase: 0, supplyPerSecondInterestRateSlopeLow: 951293759, utilization: 266666666666666666)
        // uint256 supplyRate = comet.getSupplyRate1(utilization);
        // uint256 borrowRate = comet.getBorrowRate1(utilization);
        // baseSupplyIndex_ += safe64(mulFactor(baseSupplyIndex_, supplyRate * timeElapsed));
        //     baseBorrowIndex_ += safe64(mulFactor(baseBorrowIndex_, borrowRate * timeElapsed));
        // console2.log('getUtilization', comet.getUtilization());
        // console2.log('getUtilization', comet.getUtilization());

        console2.log('Accrued', COMET_EXT.baseTrackingAccrued(address(this)));
        // comet.withdraw(address(WETH9), type(uint256).max);
        console2.log(comet.balanceOf(address(this)));
        console2.log(comet.balanceOf(bob));
        console2.log('timestamp', block.timestamp);

        // console2.log(comet.balanceOf(address(this)));
    }

    // function testCbETHSwapViaUniswap() external {
    //     swapWithNoMax(
    //         CB_ETH,
    //         CB_ETH_WHALE,
    //         1000e18,
    //         OnChainLiquidator.PoolConfig({
    //             exchange: OnChainLiquidator.Exchange.Uniswap,
    //             uniswapPoolFee: 500,
    //             swapViaWeth: false,
    //             balancerPoolId: bytes32(''),
    //             curvePool: address(0)
    //         })
    //     );
    // }

    // function testWstETHSwapViaBalancer() external {
    //     swapWithNoMax(
    //         WST_ETH,
    //         WST_ETH_WHALE,
    //         2000e18,
    //         OnChainLiquidator.PoolConfig({
    //             exchange: OnChainLiquidator.Exchange.Balancer,
    //             uniswapPoolFee: 0,
    //             swapViaWeth: false,
    //             balancerPoolId: 0x32296969ef14eb0c6d29669c550d4a0449130230000200000000000000000080,
    //             curvePool: address(0)
    //         })
    //     );
    // }

    // function testWstETHSwapViaCurve() external {
    //     swapWithNoMax(
    //         WST_ETH,
    //         WST_ETH_WHALE,
    //         2000e18,
    //         OnChainLiquidator.PoolConfig({
    //             exchange: OnChainLiquidator.Exchange.Curve,
    //             uniswapPoolFee: 0,
    //             swapViaWeth: false,
    //             balancerPoolId: bytes32(''),
    //             curvePool: address(0xDC24316b9AE028F1497c275EB9192a3Ea0f67022)
    //         })
    //     );
    // }

    // function swapWithNoMax(
    //     address asset,
    //     address whale,
    //     uint256 transferAmount,
    //     OnChainLiquidator.PoolConfig memory poolConfig
    // ) internal {
    //     uint256 initialRecipientBalance = ERC20(WETH9).balanceOf(address(this));
    //     int256 initialReserves = comet.getReserves();

    //     address[] memory liquidatableAccounts;

    //     OnChainLiquidator.PoolConfig[] memory poolConfigs = new OnChainLiquidator.PoolConfig[](1);
    //     poolConfigs[0] = poolConfig;

    //     uint256[] memory maxAmountsToPurchase = new uint256[](1);
    //     maxAmountsToPurchase[0] = type(uint256).max;

    //     address[] memory assets = new address[](1);
    //     assets[0] = asset;

    //     vm.prank(whale);
    //     ERC20(asset).transfer(address(comet), transferAmount);

    //     liquidator.absorbAndArbitrage(
    //         address(comet),
    //         liquidatableAccounts,
    //         assets,
    //         poolConfigs,
    //         maxAmountsToPurchase,
    //         USDC,
    //         500,
    //         10e18 // liquidation threshold
    //     );

    //     // expect that there is only dust (< 1 unit) left of the asset
    //     assertLt(comet.getCollateralReserves(asset), 10**ERC20(asset).decimals());

    //     // expect the base balance of the recipient to have increased
    //     assertGt(ERC20(WETH9).balanceOf(address(this)), initialRecipientBalance);

    //     // expect the protocol reserves to have increased
    //     assertGt(comet.getReserves(), initialReserves);
    // }
}
