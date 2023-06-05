// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {stdJson} from "@forge-std/StdJson.sol";

struct Config {
    string json;
}

library ConfigLib {
    using stdJson for string;

    string internal constant OWNERS_PATH = "$.owners";
    string internal constant RPC_ALIAS_PATH = "$.rpcAlias";
    string internal constant FORK_BLOCK_NUMBER_PATH = "$.forkBlockNumber";

    function getAddress(Config storage config, string memory key) internal returns (address) {
        return config.json.readAddress(string.concat("$.", key));
    }

    function getUint(Config storage config, string memory key) internal returns (uint256) {
        return config.json.readUint(string.concat("$.", key));
    }

    function getBytes(Config storage config, string memory key) internal returns (bytes memory) {
        return config.json.readBytes(string.concat("$.", key));
    }

    function getBool(Config storage config, string memory key) internal returns (bool) {
        return config.json.readBool(string.concat("$.", key));
    }

    function getAddressArray(Config storage config, string[] memory keys)
        internal
        returns (address[] memory addresses)
    {
        addresses = new address[](keys.length);

        for (uint256 i; i < keys.length; ++i) {
            addresses[i] = getAddress(config, keys[i]);
        }
    }

    function getRpcAlias(Config storage config) internal returns (string memory) {
        return config.json.readString(RPC_ALIAS_PATH);
    }

    function getForkBlockNumber(Config storage config) internal returns (uint256) {
        return config.json.readUint(FORK_BLOCK_NUMBER_PATH);
    }

    function getOwners(Config storage config) internal returns (address[] memory) {
        return config.json.readAddressArray(OWNERS_PATH);
    }
}
