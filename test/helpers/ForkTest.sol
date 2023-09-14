// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ArrayLib} from "src/libraries/ArrayLib.sol";
import {RoleModifierLib} from "src/libraries/RoleModifierLib.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import "config/Configured.sol";

import "@forge-std/Test.sol";
import "@forge-std/console2.sol";

contract ForkTest is Test, Configured {
    using ConfigLib for Config;

    uint256 internal forkId;

    address[] internal owners;

    constructor() {
        _fork();

        owners = morphoDao.getOwners();
    }

    function _fork() internal virtual {
        string memory rpcUrl = vm.rpcUrl(_rpcAlias());
        uint256 forkBlockNumber = _forkBlockNumber();

        forkId = forkBlockNumber == 0 ? vm.createSelectFork(rpcUrl) : vm.createSelectFork(rpcUrl, forkBlockNumber);
        vm.chainId(CONFIG.getChainId());
    }
}
