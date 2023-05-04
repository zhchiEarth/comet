// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import 'forge-std/Script.sol';
import 'forge-std/StdJson.sol';
import {StdCheats} from 'forge-std/StdCheats.sol';
// import {ColumbusProxy} from 'contracts/ColumbusProxy.sol';
// import {IERC20, ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import 'contracts/Comet.sol';

contract BaseScript is Script, StdCheats {
    using stdJson for string;

    string path;
    string parsedDeployData;
    // string outputDeployData;

    // address governor;
    // address keeper;
    // address proxyAdmin;

    // address columbusDeckAddress;
    // address columbusFarmAddress;
    // address YesTokenAddress;
    string[] tokens = ['USDT', 'USDC', 'BUSD', 'DAI', 'WETH', 'WBTC', 'WBNB'];

    constructor() {
        _setupNetwork();
        _loadConfig();
        // _label();
    }

    function _setupNetwork() internal {
        Chain memory chain;
        string memory bscTestnetRpc = vm.envString('BSC_TESTNET_RPC_URL');
        if (keccak256(abi.encodePacked(bscTestnetRpc)) != keccak256('')) {
            // bsc testnet
            chain = getChain('bnb_smart_chain_testnet');
            chain.rpcUrl = bscTestnetRpc;
            setChain(chain.chainAlias, chain);
        }

        string memory avalanche_fuji_rpc_url = vm.envString('AVALANCHE_FUJI_RPC_URL');

        if (keccak256(abi.encodePacked(avalanche_fuji_rpc_url)) != keccak256('')) {
            // avalanche_fuji testnet
            chain = getChain('avalanche_fuji');
            chain.rpcUrl = avalanche_fuji_rpc_url;
            setChain(chain.chainAlias, chain);
        }

        string memory polygon_mumbai_rpc_url = vm.envString('POLYGON_MUMBAI_RPC_URL');

        if (keccak256(abi.encodePacked(polygon_mumbai_rpc_url)) != keccak256('')) {
            // polygon_mumbai
            chain = getChain('polygon_mumbai');
            chain.rpcUrl = polygon_mumbai_rpc_url;
            setChain(chain.chainAlias, chain);
        }
    }

    function _loadConfig() internal {
        Chain memory chain = getChain(block.chainid);
        string memory root = vm.projectRoot();
        path = string.concat(
            root,
            string.concat('/forge/script/input/', chain.chainAlias, '.json')
        );
        parsedDeployData = vm.readFile(path);
        // string memory output = string.concat(
        //     root,
        //     string.concat('/forge/script/output/', chain.chainAlias, '.json')
        // );
        // outputDeployData = vm.readFile(output);

        // governor = parsedDeployData.readAddress('.governor');
        // keeper = parsedDeployData.readAddress('.keeper');
        // proxyAdmin = parsedDeployData.readAddress('.proxyAdmin');
        // columbusDeckAddress = parsedDeployData.readAddress('.columbusDeck');
        // columbusFarmAddress = parsedDeployData.readAddress('.columbusFarm');
        // YesTokenAddress = parsedDeployData.readAddress('.yesToken');
    }

    function _label() internal {
        // vm.label(proxyAdmin, 'proxyAdmin');
        // vm.label(columbusDeckAddress, 'columbusDeck');
        // vm.label(columbusFarmAddress, 'columbusFarm');
        // vm.label(YesTokenAddress, 'YesToken');
    }

    function _writeConfigVaule(address vault, string memory key) internal {
        vm.writeJson(vm.toString(vault), path, key);
    }

    function _writeConfigVaule(uint vault, string memory key) internal {
        vm.writeJson(vm.toString(vault), path, key);
    }

    // function _getToken(string memory key) internal view returns (address) {
    //     return parsedDeployData.readAddress(string.concat('.tokens.', key, '.addr'));
    // }

    function _isEmpty(address addr_) internal pure returns (bool) {
        return (addr_ == address(0) || addr_ == address(32));
    }

    function _readAddress(string memory key) internal returns (address) {
        return parsedDeployData.readAddress(key);
    }

    function _readComet(string memory key) internal returns (Comet) {
        return Comet(payable(parsedDeployData.readAddress(key)));
    }

    function _readUint(string memory key) internal returns (uint256) {
        return parsedDeployData.readUint(key);
    }

    function _readString(string memory key) internal returns (string memory) {
        return parsedDeployData.readString(key);
    }

    function _readStringArray(string memory key) internal returns (string[] memory) {
        return parsedDeployData.readStringArray(key);
    }
}
