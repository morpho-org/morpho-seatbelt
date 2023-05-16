// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Config, ConfigLib} from "config/ConfigLib.sol";

import {StdChains, VmSafe} from "@forge-std/StdChains.sol";

import {Types} from "@morpho-aave-v3/src/libraries/Types.sol";
import {IMorpho} from "@morpho-aave-v3/src/interfaces/IMorpho.sol";

import {Ownable} from "@openzeppelin-contracts/contracts/access/Ownable.sol";
import {ProxyAdmin} from "@openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

import {IAvatar} from "src/interfaces/IAvatar.sol";

contract Configured is StdChains {
    using ConfigLib for Config;

    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    Chain internal chain;
    Config internal config;

    function _network() internal view virtual returns (string memory) {
        try vm.envString("NETWORK") returns (string memory configNetwork) {
            return configNetwork;
        } catch {
            return "ethereum-mainnet";
        }
    }

    function _initConfig() internal returns (Config storage) {
        if (bytes(config.json).length == 0) {
            string memory root = vm.projectRoot();
            string memory path = string.concat(root, "/config/", _network(), ".json");

            config.json = vm.readFile(path);
        }

        return config;
    }

    function _loadConfig() internal virtual {
        string memory rpcAlias = config.getRpcAlias();

        chain = getChain(rpcAlias);        
    }
}
