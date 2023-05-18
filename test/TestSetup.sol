// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ConfigLib, Config} from "config/ConfigLib.sol";
import {Configured} from "config/Configured.sol";
import {console2} from "@forge-std/console2.sol";
import {Vm} from "@forge-std/Vm.sol";
import {Role, TargetAddress, Transaction, Operation} from "src/libraries/Types.sol";
import {RoleHelperLib} from "test/RoleHelperLib.sol";

import {IMorphoCompoundGovernance} from "src/interfaces/IMorphoCompoundGovernance.sol";
import {IMorphoAaveV2Governance} from "src/interfaces/IMorphoAaveV2Governance.sol";
import {IMorphoAaveV3Governance} from "src/interfaces/IMorphoAaveV3Governance.sol";
import {IAvatar} from "src/interfaces/IAvatar.sol";
import {ISafe} from "src/interfaces/ISafe.sol";
import {IDelay} from "src/interfaces/IDelay.sol";
import {IRoles} from "src/interfaces/IRoles.sol";

import {Ownable} from "@openzeppelin-contracts/contracts/access/Ownable.sol";
import {ProxyAdmin} from "@openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

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
    IMorphoCompoundGovernance public morphoCompound;
    IMorphoAaveV2Governance public morphoAaveV2;
    IMorphoAaveV3Governance public morphoAaveV3;

    address[] internal roleMembers;
    bytes4[] internal delaySelectors;
    bytes4[] internal mcSelectors;
    bytes4[] internal ma2Selectors;
    bytes4[] internal ma3Selectors;

    Config internal txConfig;

    function setUp() public virtual {
        _initConfig();
        _loadConfig();
        _populateMembersToCheck();
        _populateDelaySelectors();
        _populateMcSelectors();
        _populateMa2Selectors();
        _populateMa3FunctionSelectors();
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
        morphoCompound = IMorphoCompoundGovernance(networkConfig.getAddress("morpho-compound"));
        morphoAaveV2 = IMorphoAaveV2Governance(networkConfig.getAddress("morpho-aave-v2"));
        morphoAaveV3 = IMorphoAaveV3Governance(networkConfig.getAddress("morpho-aave-v3"));
    }

    function _addModule(IAvatar avatar, address module) internal {
        vm.prank(address(avatar));
        avatar.enableModule(module);
    }

    function _populateMembersToCheck() internal {
        roleMembers.push(address(operator));
        roleMembers.push(address(morphoDao));
    }

    function _getTxData(string memory txName) internal returns (Transaction memory transaction) {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/config/transactions/", txName, ".json");
        txConfig.json = vm.readFile(path);
        transaction.to = txConfig.getAddress("to");
        transaction.value = txConfig.getUint("value");
        transaction.data = txConfig.getBytes("data");
        transaction.op = txConfig.getBool("op") ? Operation.DelegateCall : Operation.Call;
    }

    function _populateDelaySelectors() internal {
        delaySelectors.push(delayModifier.enableModule.selector);
        delaySelectors.push(delayModifier.disableModule.selector);
        delaySelectors.push(delayModifier.execTransactionFromModule.selector);
        delaySelectors.push(delayModifier.execTransactionFromModuleReturnData.selector);
        delaySelectors.push(delayModifier.isModuleEnabled.selector);
        delaySelectors.push(delayModifier.getModulesPaginated.selector);
        delaySelectors.push(delayModifier.setUp.selector);
        delaySelectors.push(delayModifier.setTxCooldown.selector);
        delaySelectors.push(delayModifier.setTxExpiration.selector);
        delaySelectors.push(delayModifier.setTxNonce.selector);
        delaySelectors.push(delayModifier.executeNextTx.selector);
        delaySelectors.push(delayModifier.skipExpired.selector);
    }

    function _populateMcSelectors() internal {
        mcSelectors.push(morphoCompound.setMaxSortedUsers.selector);
        mcSelectors.push(morphoCompound.setDefaultMaxGasForMatching.selector);
        mcSelectors.push(morphoCompound.setIncentivesVault.selector);
        mcSelectors.push(morphoCompound.setRewardsManager.selector);
        mcSelectors.push(morphoCompound.setPositionsManager.selector);
        mcSelectors.push(morphoCompound.setInterestRatesManager.selector);
        mcSelectors.push(morphoCompound.setTreasuryVault.selector);
        mcSelectors.push(morphoCompound.setDustThreshold.selector);
        mcSelectors.push(morphoCompound.setIsP2PDisabled.selector);
        mcSelectors.push(morphoCompound.setReserveFactor.selector);
        mcSelectors.push(morphoCompound.setP2PIndexCursor.selector);
        mcSelectors.push(morphoCompound.setIsPausedForAllMarkets.selector);
        mcSelectors.push(morphoCompound.setIsClaimRewardsPaused.selector);
        mcSelectors.push(morphoCompound.setIsSupplyPaused.selector);
        mcSelectors.push(morphoCompound.setIsBorrowPaused.selector);
        mcSelectors.push(morphoCompound.setIsWithdrawPaused.selector);
        mcSelectors.push(morphoCompound.setIsRepayPaused.selector);
        mcSelectors.push(morphoCompound.setIsLiquidateCollateralPaused.selector);
        mcSelectors.push(morphoCompound.setIsLiquidateBorrowPaused.selector);
        mcSelectors.push(morphoCompound.claimToTreasury.selector);
        mcSelectors.push(morphoCompound.createMarket.selector);
    }

    function _populateMa2Selectors() internal {
        ma2Selectors.push(morphoAaveV2.setMaxSortedUsers.selector);
        ma2Selectors.push(morphoAaveV2.setDefaultMaxGasForMatching.selector);
        ma2Selectors.push(morphoAaveV2.setExitPositionsManager.selector);
        ma2Selectors.push(morphoAaveV2.setEntryPositionsManager.selector);
        ma2Selectors.push(morphoAaveV2.setInterestRatesManager.selector);
        ma2Selectors.push(morphoAaveV2.setTreasuryVault.selector);
        ma2Selectors.push(morphoAaveV2.setIsP2PDisabled.selector);
        ma2Selectors.push(morphoAaveV2.setReserveFactor.selector);
        ma2Selectors.push(morphoAaveV2.setP2PIndexCursor.selector);
        ma2Selectors.push(morphoAaveV2.setIsPausedForAllMarkets.selector);
        ma2Selectors.push(morphoAaveV2.setIsSupplyPaused.selector);
        ma2Selectors.push(morphoAaveV2.setIsBorrowPaused.selector);
        ma2Selectors.push(morphoAaveV2.setIsWithdrawPaused.selector);
        ma2Selectors.push(morphoAaveV2.setIsRepayPaused.selector);
        ma2Selectors.push(morphoAaveV2.setIsLiquidateCollateralPaused.selector);
        ma2Selectors.push(morphoAaveV2.setIsLiquidateBorrowPaused.selector);
        ma2Selectors.push(morphoAaveV2.claimToTreasury.selector);
        ma2Selectors.push(morphoAaveV2.createMarket.selector);
        ma2Selectors.push(morphoAaveV2.increaseP2PDeltas.selector);
    }

    function _populateMa3FunctionSelectors() internal {
        ma3Selectors.push(morphoAaveV3.createMarket.selector);
        ma3Selectors.push(morphoAaveV3.increaseP2PDeltas.selector);
        ma3Selectors.push(morphoAaveV3.claimToTreasury.selector);
        ma3Selectors.push(morphoAaveV3.setPositionsManager.selector);
        ma3Selectors.push(morphoAaveV3.setRewardsManager.selector);
        ma3Selectors.push(morphoAaveV3.setTreasuryVault.selector);
        ma3Selectors.push(morphoAaveV3.setDefaultIterations.selector);
        ma3Selectors.push(morphoAaveV3.setP2PIndexCursor.selector);
        ma3Selectors.push(morphoAaveV3.setReserveFactor.selector);
        ma3Selectors.push(morphoAaveV3.setAssetIsCollateralOnPool.selector);
        ma3Selectors.push(morphoAaveV3.setAssetIsCollateral.selector);
        ma3Selectors.push(morphoAaveV3.setIsClaimRewardsPaused.selector);
        ma3Selectors.push(morphoAaveV3.setIsPaused.selector);
        ma3Selectors.push(morphoAaveV3.setIsPausedForAllMarkets.selector);
        ma3Selectors.push(morphoAaveV3.setIsSupplyPaused.selector);
        ma3Selectors.push(morphoAaveV3.setIsSupplyCollateralPaused.selector);
        ma3Selectors.push(morphoAaveV3.setIsBorrowPaused.selector);
        ma3Selectors.push(morphoAaveV3.setIsRepayPaused.selector);
        ma3Selectors.push(morphoAaveV3.setIsWithdrawPaused.selector);
        ma3Selectors.push(morphoAaveV3.setIsWithdrawCollateralPaused.selector);
        ma3Selectors.push(morphoAaveV3.setIsLiquidateBorrowPaused.selector);
        ma3Selectors.push(morphoAaveV3.setIsLiquidateCollateralPaused.selector);
        ma3Selectors.push(morphoAaveV3.setIsP2PDisabled.selector);
        ma3Selectors.push(morphoAaveV3.setIsDeprecated.selector);
    }
}
