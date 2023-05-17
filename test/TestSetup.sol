// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ConfigLib, Config} from "config/ConfigLib.sol";
import {Configured} from "config/Configured.sol";

import {console2} from "@forge-std/console2.sol";
import {Vm} from "@forge-std/Vm.sol";

import {Types} from "@morpho-aave-v3/src/libraries/Types.sol";
import {IMorpho} from "@morpho-aave-v3/src/interfaces/IMorpho.sol";

import {Ownable} from "@openzeppelin-contracts/contracts/access/Ownable.sol";
import {ProxyAdmin} from "@openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

import {Role, TargetAddress} from "src/libraries/Types.sol";

import {IAvatar} from "src/interfaces/IAvatar.sol";
import {ISafe} from "src/interfaces/ISafe.sol";
import {IDelay} from "src/interfaces/IDelay.sol";
import {IRoles} from "src/interfaces/IRoles.sol";

import {RoleHelperLib} from "test/RoleHelperLib.sol";

contract TestSetup is Test, Configured {
    using ConfigLib for Config;
    using RoleHelperLib for IRoles;

    uint256 forkId;

    ISafe public morphoAdmin;
    ISafe public morphoDao;
    ISafe public operator;
    IDelay public delayModifier;
    IRoles public roleModifier;

    ProxyAdmin public proxyAdmin;
    IMorpho public morpho;

    function setUp() public virtual {
        _initConfig();
        _loadConfig();
    }

    function _loadConfig() internal virtual override {
        super._loadConfig();
        uint256 forkBlockNumber = networkConfig.getForkBlockNumber();
        if (forkBlockNumber == 0) {
            forkId = vm.createSelectFork(chain.rpcUrl);
        } else {
            forkId = vm.createSelectFork(chain.rpcUrl, networkConfig.getForkBlockNumber());
        }
        morphoAdmin = ISafe(networkConfig.getAddress("morphoAdmin"));
        morphoDao = ISafe(networkConfig.getAddress("morphoDao"));
        operator = ISafe(networkConfig.getAddress("operator"));
        delayModifier = IDelay(networkConfig.getAddress("delayModifier"));
        roleModifier = IRoles(networkConfig.getAddress("roleModifier"));
        proxyAdmin = ProxyAdmin(networkConfig.getAddress("proxyAdmin"));
        morpho = IMorpho(networkConfig.getAddress("morpho"));
    }

    function _addModule(IAvatar avatar, address module) internal {
        vm.prank(address(avatar));
        avatar.enableModule(module);
    }
}
