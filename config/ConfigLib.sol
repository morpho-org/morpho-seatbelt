// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {stdJson} from "@forge-std/StdJson.sol";

struct Config {
    string json;
}

library ConfigLib {
    using stdJson for string;

    string internal constant CHAIN_ID_PATH = "$.chainId";
    string internal constant RPC_ALIAS_PATH = "$.rpcAlias";
    string internal constant FORK_BLOCK_NUMBER_PATH = "$.forkBlockNumber";

    function getAddress(Config storage config, string memory key) internal returns (address) {
        return config.json.readAddress(string.concat("$.", key));
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

    function getChainId(Config storage config) internal returns (uint256) {
        return config.json.readUint(CHAIN_ID_PATH);
    }

    function getRpcAlias(Config storage config) internal returns (string memory) {
        return config.json.readString(RPC_ALIAS_PATH);
    }

    function getForkBlockNumber(Config storage config) internal returns (uint256) {
        return config.json.readUint(FORK_BLOCK_NUMBER_PATH);
    }
}
