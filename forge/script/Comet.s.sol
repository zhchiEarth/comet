// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import 'forge-std/Script.sol';
import 'forge-std/StdJson.sol';
import 'contracts/CometConfiguration.sol';
import 'contracts/CometProxyAdmin.sol';
import 'contracts/CometExt.sol';
import 'contracts/CometFactory.sol';
import 'contracts/Comet.sol';
import 'contracts/Configurator.sol';
import 'contracts/ConfiguratorProxy.sol';
import 'contracts/test/SimplePriceFeed.sol';
import 'contracts/vendor/proxy/transparent/TransparentUpgradeableProxy.sol';

contract CometScript is Script {
    using stdJson for string;
    struct AssetInfo {
        address addr;
        uint8 decimals;
        int256 price;
    }

    struct CometToken {
        AssetInfo asset;
        address baseToken;
        uint8 decimals;
        string name;
        string symbol;
    }

    function run() external {
        Chain memory chain = getChain(block.chainid);

        string memory root = vm.projectRoot();
        string memory path = string.concat(
            root,
            string.concat('/forge/script/input/', chain.chainAlias, '.json')
        );
        string memory output = string.concat(
            root,
            string.concat('/forge/script/output/', chain.chainAlias, '.json')
        );
        string memory parsedDeployData = vm.readFile(path);

        address governor = parsedDeployData.readAddress('.governor');
        address pauseGuardian = parsedDeployData.readAddress('.pauseGuardian');

        address configurator = parsedDeployData.readAddress('.configurator');
        address proxyAdminAddress = parsedDeployData.readAddress('.proxyAdmin');
        // address cometRewards = parsedDeployData.readAddress('.cometRewards');
        address cometFactory = parsedDeployData.readAddress('.cometFactory');

        bytes memory rawAsset = vm.parseJson(parsedDeployData, '.tokens');
        CometToken[] memory cometTokens = abi.decode(rawAsset, (CometToken[]));

        for (uint256 i; i < cometTokens.length; i++) {
            vm.startBroadcast();

            CometToken memory cometToken = cometTokens[i];
            AssetInfo memory assetInfo = cometTokens[i].asset;

            SimplePriceFeed assetPriceFeed = new SimplePriceFeed(assetInfo.price, 8);
            SimplePriceFeed baseTokenPriceFeed = new SimplePriceFeed(1e8, 8);

            CometConfiguration.ExtConfiguration memory extConfig = CometConfiguration
                .ExtConfiguration({
                    name32: bytes32(abi.encodePacked(cometToken.name)),
                    symbol32: bytes32(abi.encodePacked(cometToken.symbol))
                });

            CometExt cometExt = new CometExt(extConfig);

            bytes memory _data;
            TransparentUpgradeableProxy cometProxy = new TransparentUpgradeableProxy(
                cometFactory,
                proxyAdminAddress,
                _data
            );
            Configurator configuratorProxy = Configurator(configurator);

            // 8. setFactory
            configuratorProxy.setFactory(address(cometProxy), cometFactory);

            // 9. configuratorProxy.setConfiguration
            // function setConfiguration(address cometProxy, Configuration calldata newConfiguration)
            CometConfiguration.AssetConfig[]
                memory assetConfigs = new CometConfiguration.AssetConfig[](1);
            assetConfigs[0] = CometConfiguration.AssetConfig({
                asset: assetInfo.addr,
                priceFeed: address(assetPriceFeed),
                decimals: assetInfo.decimals,
                borrowCollateralFactor: 9e17,
                liquidateCollateralFactor: 93e16,
                liquidationFactor: 95e16,
                supplyCap: uint128(10000000000 * 10**assetInfo.decimals)
            });

            CometConfiguration.Configuration memory newConfiguration = CometConfiguration
                .Configuration({
                    governor: governor,
                    pauseGuardian: pauseGuardian,
                    baseToken: cometToken.baseToken,
                    baseTokenPriceFeed: address(baseTokenPriceFeed),
                    extensionDelegate: address(cometExt),
                    supplyKink: 8e17,
                    supplyPerYearInterestRateSlopeLow: 32500000000000000,
                    supplyPerYearInterestRateSlopeHigh: 400000000000000000,
                    supplyPerYearInterestRateBase: 0,
                    borrowKink: 8e17,
                    borrowPerYearInterestRateSlopeLow: 35000000000000000,
                    borrowPerYearInterestRateSlopeHigh: 250000000000000000,
                    borrowPerYearInterestRateBase: 15000000000000000,
                    storeFrontPriceFactor: 5e17,
                    trackingIndexScale: 1e15,
                    baseTrackingSupplySpeed: 0,
                    baseTrackingBorrowSpeed: 0,
                    baseMinForRewards: uint104(1000000 * 10**cometToken.decimals),
                    baseBorrowMin: uint104(1 * 10**cometToken.decimals), // 最小借款金额
                    targetReserves: uint104(5000000000000000 * 10**cometToken.decimals),
                    assetConfigs: assetConfigs
                });
            configuratorProxy.setConfiguration(address(cometProxy), newConfiguration);

            CometProxyAdmin proxyAdmin = CometProxyAdmin(proxyAdminAddress);

            //  cometProxyAdmin.deployUpgradeToAndCall
            // function deployUpgradeToAndCall(Deployable configuratorProxy, TransparentUpgradeableProxy cometProxy, bytes memory data)  {}
            bytes memory dataNew = abi.encodeWithSignature('initializeStorage()');
            proxyAdmin.deployUpgradeToAndCall(
                Deployable(address(configuratorProxy)),
                cometProxy,
                dataNew
            );
            vm.stopBroadcast();

            vm.writeJson(
                vm.toString(address(cometProxy)),
                output,
                string.concat('.cometProxy.', cometToken.symbol)
            );
            vm.writeJson(
                vm.toString(address(cometExt)),
                output,
                string.concat('.cometExt.', cometToken.symbol)
            );
        }
    }
}
