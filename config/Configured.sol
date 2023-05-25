// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAvatar} from "src/interfaces/IAvatar.sol";

import {Operation} from "src/libraries/Types.sol";

import {Config, ConfigLib} from "config/ConfigLib.sol";
import {StdChains, VmSafe} from "@forge-std/StdChains.sol";

import {Ownable} from "@openzeppelin-contracts/contracts/access/Ownable.sol";
import {ProxyAdmin} from "@openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract Configured is StdChains {
    using ConfigLib for Config;

    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    Chain internal chain;
    Config internal networkConfig;

    function _network() internal view virtual returns (string memory) {
        try vm.envString("NETWORK") returns (string memory network) {
            return network;
        } catch {
            return "ethereum-mainnet";
        }
    }

    function _initConfig() internal returns (Config storage) {
        if (bytes(networkConfig.json).length == 0) {
            string memory root = vm.projectRoot();
            string memory path = string.concat(root, "/config/networks/", _network(), ".json");

            networkConfig.json = vm.readFile(path);
        }

        return networkConfig;
    }

    function _loadConfig() internal virtual {
        string memory rpcAlias = networkConfig.getRpcAlias();

        chain = getChain(rpcAlias);        
    }
}
