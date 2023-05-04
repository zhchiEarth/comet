// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import 'forge/script/BaseScript.sol';
import 'contracts/test/FaucetToken.sol';
import 'contracts/test/FaucetWETH.sol';

// import 'contracts/Comet.sol';

// forge script forge/script/03_Apr.s.sol:AprScript --rpc-url   ${AVALANCHE_FUJI_RPC_URL}  --broadcast
// forge script forge/script/03_Apr.s.sol:AprScript --rpc-url   ${POLYGON_MUMBAI_RPC_URL}  --broadcast
// forge script forge/script/03_Apr.s.sol:AprScript --rpc-url   ${OPTIMISM_GOERLI_RPC_URL}  --broadcast

// 使用anvil测试
// anvil --fork-url https://avalanche-fuji.infura.io/v3/${INFURA_KEY}
// anvil --fork-url https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_MUMBAI_KEY}
// forge script forge/script/03_Apr.s.sol:AprScript --rpc-url  http://127.0.0.1:8545  --broadcast -vvvv
contract AprScript is BaseScript {
    address _accountDemo;
    address _account7;

    function run() external {
        _accountDemo = 0xc2767675300D5dB7E0802F06D680d10027e7e7BF;
        _account7 = 0x72488bAa718F52B76118C79168E55c209056A2E6;

        for (uint8 i = 0; i < tokens.length; i++) {
            _deploy(tokens[i], i);
        }
    }

    function _deploy(string memory key, uint8 index) internal {
        // console2.log(key, index);
        // console2.log(path);
        // console2.log(string.concat('.cometProxy.c', key, 'v3'));
        Comet comet = _readComet(string.concat('.cometProxy.c', key, 'v3'));
        uint256 utilization = comet.getUtilization();
        if (comet.getUtilization() > 0) {
            return;
        }

        address baseTokenAddress = _readAddress(
            string.concat('.tokens[', vm.toString(index), '].baseToken')
        );
        address collateralTokenAddress = _readAddress(
            string.concat('.tokens[', vm.toString(index), '].asset.addr')
        );
        uint baseTokenPrice = 1e8;
        uint collateralTokenPrice = _readUint(
            string.concat('.tokens[', vm.toString(index), '].asset.price')
        );

        ERC20 baseToken = ERC20(baseTokenAddress);
        ERC20 collateralToken = ERC20(collateralTokenAddress);

        uint baseTokenAmount = 1000000 * 10 ** baseToken.decimals();
        uint collateralTokenAmount = 1000000 * 10 ** collateralToken.decimals();
        // 没有这么多btc
        if (keccak256(abi.encodePacked('WBTC')) == keccak256(abi.encodePacked(key))) {
            baseTokenAmount = 1000 * 10 ** baseToken.decimals();
            collateralTokenAmount = 1000 * 10 ** collateralToken.decimals();
        }
        if (baseTokenPrice > collateralTokenPrice) {
            uint pricePercent = (baseTokenPrice * 1e18) / collateralTokenPrice;
            collateralTokenAmount = (collateralTokenAmount * pricePercent) / 1e18;
        } else {
            uint pricePercent = (collateralTokenPrice * 1e18) / baseTokenPrice;
            collateralTokenAmount = (collateralTokenAmount * 1e18) / pricePercent;
        }

        uint256 _account7_PK = vm.envUint('ACCOUNT7_PRIVATE_KEY');
        uint256 _accountDemo_PK = vm.envUint('PRIVATE_KEY');
        vm.startBroadcast(_account7_PK);
        // vm.startPrank(_account7);
        baseToken.approve(address(comet), baseTokenAmount);
        comet.supply(address(baseToken), baseTokenAmount);

        collateralToken.approve(_accountDemo, collateralTokenAmount);
        collateralToken.transfer(_accountDemo, collateralTokenAmount);
        // vm.stopPrank();
        vm.stopBroadcast();

        vm.startBroadcast(_accountDemo_PK);
        // vm.startPrank(_accountDemo);
        collateralToken.approve(address(comet), collateralTokenAmount);
        comet.supply(address(collateralToken), collateralTokenAmount);

        // uint withdrawAmount = (baseTokenAmount * 90) / 100; // 0.9抵押率
        uint withdrawAmount = (baseTokenAmount * 80) / 100; // 最大抵押率0.9，剩一点
        comet.withdraw(address(baseToken), withdrawAmount);
        // vm.stopPrank();
        vm.stopBroadcast();
        utilization = comet.getUtilization();
        console2.log('utilization', comet.getUtilization());
        assert(utilization > 0);
    }
}
