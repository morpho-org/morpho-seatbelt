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
        uint256 forkBlockNumber = config.getForkBlockNumber();
        if(forkBlockNumber == 0) {
            forkId = vm.createSelectFork(chain.rpcUrl);
        }
        else {
            forkId = vm.createSelectFork(chain.rpcUrl, config.getForkBlockNumber());
        }
        morphoAdmin = ISafe(config.getAddress("morphoAdmin"));
        morphoDao = ISafe(config.getAddress("morphoDao"));
        operator = ISafe(config.getAddress("operator"));
        delayModifier = IDelay(config.getAddress("delayModifier"));
        roleModifier = IRoles(config.getAddress("roleModifier"));
        proxyAdmin = ProxyAdmin(config.getAddress("proxyAdmin"));
        morpho = IMorpho(config.getAddress("morpho"));
    }
}
