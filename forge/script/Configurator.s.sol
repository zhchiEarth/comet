// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import 'forge-std/Script.sol';
import 'forge-std/StdJson.sol';
import 'contracts/CometProxyAdmin.sol';
import 'contracts/CometRewards.sol';
import 'contracts/CometFactory.sol';
import 'contracts/Configurator.sol';
import 'contracts/ConfiguratorProxy.sol';

contract ConfiguratorScript is Script {
    using stdJson for string;

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

        vm.startBroadcast();
        // deploy Configurator
        Configurator configurator = new Configurator();
        CometProxyAdmin proxyAdmin = new CometProxyAdmin();
        // deploy CometRewards
        CometRewards cometRewards = new CometRewards(governor);
        //  ConfiguratorProxy
        bytes memory data = abi.encodeWithSignature('initialize(address)', governor);
        ConfiguratorProxy configuratorProxy = new ConfiguratorProxy(
            address(configurator),
            address(proxyAdmin),
            data
        );
        CometFactory cometFactory = new CometFactory();

        vm.stopBroadcast();

        vm.writeJson(vm.toString(address(configuratorProxy)), path, '.configurator');
        vm.writeJson(vm.toString(address(configurator)), path, '.configuratorImpl');
        vm.writeJson(vm.toString(address(proxyAdmin)), path, '.proxyAdmin');
        vm.writeJson(vm.toString(address(cometRewards)), path, '.cometRewards');
        vm.writeJson(vm.toString(address(cometFactory)), path, '.cometFactory');

        // output
        vm.writeJson(vm.toString(address(configuratorProxy)), output, '.configurator');
        vm.writeJson(vm.toString(address(configurator)), output, '.configuratorImpl');
        vm.writeJson(vm.toString(address(proxyAdmin)), output, '.proxyAdmin');
        vm.writeJson(vm.toString(address(cometRewards)), output, '.cometRewards');
        vm.writeJson(vm.toString(address(cometFactory)), output, '.cometFactory');
    }
}
