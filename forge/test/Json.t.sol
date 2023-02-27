// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';
import 'forge-std/StdJson.sol';
import '../../contracts/Comet.sol';
import '../../contracts/CometConfiguration.sol';

contract JsonTest is Test {
    using stdJson for string;

    Comet public comet;

    function setUp() public {
        // XXX
    }

    struct Configuration {
        // address governor;
        // address pauseGuardian;
        // address baseToken;
        // address baseTokenPriceFeed;
        // address extensionDelegate;
        uint64 supplyKink;
        uint64 supplyPerYearInterestRateSlopeLow;
        uint64 supplyPerYearInterestRateSlopeHigh;
        uint64 supplyPerYearInterestRateBase;
        uint64 borrowKink;
        uint64 borrowPerYearInterestRateSlopeLow;
        uint64 borrowPerYearInterestRateSlopeHigh;
        uint64 borrowPerYearInterestRateBase;
        uint64 storeFrontPriceFactor;
        uint64 trackingIndexScale;
        uint64 baseTrackingSupplySpeed;
        uint64 baseTrackingBorrowSpeed;
        uint104 baseMinForRewards;
        uint104 baseBorrowMin;
        uint104 targetReserves;
    }

    function testJson() public {
        // CometConfiguration.Configuration newConfiguration = CometConfiguration.Configuration();
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, '/forge/script/usdc.json');
        string memory json = vm.readFile(path);
        bytes memory transactionDetails = json.parseRaw('.USDC.Configuration');

        // bytes memory targetReserves = json.parseRaw('.USDC.Configuration.targetReserves');

        Configuration memory configuration = abi.decode(transactionDetails, (Configuration));

        console2.log(configuration.targetReserves);
        // bytes memory transactionDetails = json.parseRaw('.USDC.Configuration.governor');
        // // Configuration memory rawTxDetail = abi.decode(transactionDetails, (Configuration));
        // address governor = abi.decode(transactionDetails, (address));
    }

    function testWriteJson() public {
        // CometConfiguration.Configuration newConfiguration = CometConfiguration.Configuration();
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, '/forge/script/config.json');
        // string memory json = vm.readFile(path);
        // bytes memory transactionDetails = json.parseRaw('.USDC.Configuration');

        // bytes memory targetReserves = json.parseRaw('.USDC.Configuration.targetReserves');
        string memory jsonObj3 = 'governor';
        vm.writeJson(jsonObj3, path, '.governor');

        // Configuration memory configuration = abi.decode(transactionDetails, (Configuration));

        // console2.log(configuration.targetReserves);
        // bytes memory transactionDetails = json.parseRaw('.USDC.Configuration.governor');
        // // Configuration memory rawTxDetail = abi.decode(transactionDetails, (Configuration));
        // address governor = abi.decode(transactionDetails, (address));
    }
}
