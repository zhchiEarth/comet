// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import 'forge-std/Script.sol';
import '../../contracts/test/FaucetToken.sol';
import '../../contracts/test/FaucetWETH.sol';

contract TokenScript is Script {
    function run() external {
        Chain memory chain = getChain(block.chainid);
        string memory root = vm.projectRoot();
        string memory path = string.concat(
            root,
            string.concat('/forge/script/input/', chain.chainAlias, '.json')
        );

        string memory parsedDeployData = vm.readFile(path);

        vm.startBroadcast();
        FaucetToken USDT = new FaucetToken(1000000000001e18, 'USDT', 6, 'USDT');
        FaucetToken USDC = new FaucetToken(1000000000001e18, 'USDC', 6, 'USDC');
        FaucetToken BUSD = new FaucetToken(1000000000001e18, 'BUSD', 18, 'BUSD');
        FaucetToken DAI = new FaucetToken(1000000000001e18, 'DAI', 18, 'DAI');
        FaucetToken WETH = new FaucetToken(1000000000001e18, 'WETH', 18, 'WETH');
        FaucetToken WBTC = new FaucetToken(1000000000001e18, 'WBTC', 8, 'WBTC');
        FaucetToken WBNB = new FaucetToken(1000000000001e18, 'WBNB', 18, 'WBNB');

        vm.writeJson(vm.toString(address(USDT)), path, '.tokens[0].baseToken');
        vm.writeJson(vm.toString(address(USDC)), path, '.tokens[1].baseToken');
        vm.writeJson(vm.toString(address(BUSD)), path, '.tokens[2].baseToken');
        vm.writeJson(vm.toString(address(DAI)), path, '.tokens[3].baseToken');
        vm.writeJson(vm.toString(address(WETH)), path, '.tokens[4].baseToken');
        vm.writeJson(vm.toString(address(WBTC)), path, '.tokens[5].baseToken');
        vm.writeJson(vm.toString(address(WBNB)), path, '.tokens[6].baseToken');

        // Collateral assets
        vm.writeJson(vm.toString(address(WETH)), path, '.tokens[0].asset.addr');
        vm.writeJson(vm.toString(address(WETH)), path, '.tokens[1].asset.addr');
        vm.writeJson(vm.toString(address(WETH)), path, '.tokens[2].asset.addr');
        vm.writeJson(vm.toString(address(WETH)), path, '.tokens[3].asset.addr');
        vm.writeJson(vm.toString(address(WETH)), path, '.tokens[5].asset.addr');
        vm.writeJson(vm.toString(address(WETH)), path, '.tokens[6].asset.addr');

        vm.writeJson(vm.toString(address(WBTC)), path, '.tokens[4].asset.addr');

        vm.stopBroadcast();
    }
}
