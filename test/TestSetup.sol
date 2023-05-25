// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ConfigLib, Config} from "config/ConfigLib.sol";
import {Configured} from "config/Configured.sol";
import {console2} from "@forge-std/console2.sol";
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

///@notice The DAO can call all the functions of governance including tthe ones that can be used by Morpho Operator.
///@notice It just needs to be executed through the Delay Modifier.
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
    bytes4[] internal delaySelectorsAllowedDao;
    bytes4[] internal roleSelectors;
    bytes4[] internal mcSelectorsOperator;
    bytes4[] internal ma2SelectorsOperator;
    bytes4[] internal ma3SelectorsOperator;
    bytes4[] internal mcSelectorsAdmin;
    bytes4[] internal ma2SelectorsAdmin;
    bytes4[] internal ma3SelectorsAdmin;

    mapping(bytes4 => string) mcSelectorFunctionMap;
    mapping(bytes4 => string) ma2SelectorFunctionMap;
    mapping(bytes4 => string) ma3SelectorFunctionMap;

    mapping(bytes4 => string) delaySelectorFunctionMap;
    mapping(bytes4 => string) roleSelectorFunctionMap;

    Config internal txConfig;

    function setUp() public virtual {
        _initConfig();
        _loadConfig();
        _populateMembersToCheck();
        _populateDelaySelectors();
        _populateRoleSelectors();
        _populateMcFunctionSelectors();
        _populateMa2FunctionSelectors();
        _populateMa3FunctionSelectors();
        _populateMcMappingSelectorsFunctionName();
        _populateMa2MappingSelectorsFunctionName();
        _populateMa3MappingSelectorsFunctionName();
        _populateRoleMappingSelectorsFunctionName();
        _populateDelayMappingSelectorsFunctionName();
    }

    function _loadConfig() internal virtual override {
        super._loadConfig();
        uint256 forkBlockNumber = networkConfig.getForkBlockNumber();
        if (forkBlockNumber == 0) {
            forkId = vm.createSelectFork(chain.rpcUrl);
        } else {
            forkId = vm.createSelectFork(chain.rpcUrl, forkBlockNumber);
        }
        morphoAdmin = ISafe(networkConfig.getAddress("morphoAdmin"));
        morphoDao = ISafe(networkConfig.getAddress("morphoDao"));
        operator = ISafe(networkConfig.getAddress("operator"));
        delayModifier = IDelay(networkConfig.getAddress("delayModifier"));
        roleModifier = IRoles(networkConfig.getAddress("roleModifier"));
        proxyAdmin = ProxyAdmin(networkConfig.getAddress("proxyAdmin"));
        morphoCompound = IMorphoCompoundGovernance(networkConfig.getAddress("morphoCompound"));
        morphoAaveV2 = IMorphoAaveV2Governance(networkConfig.getAddress("morphoAaveV2"));
        morphoAaveV3 = IMorphoAaveV3Governance(networkConfig.getAddress("morphoAaveV3"));
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

    function _populateDelayMappingSelectorsFunctionName() internal {
        delaySelectorFunctionMap[delayModifier.enableModule.selector] = string("DelayModifier.enableModule");
        delaySelectorFunctionMap[delayModifier.disableModule.selector] = string("DelayModifier.disableModule");
        delaySelectorFunctionMap[delayModifier.execTransactionFromModule.selector] =
            string("DelayModifier.execTransactionFromModule");
        delaySelectorFunctionMap[delayModifier.execTransactionFromModuleReturnData.selector] =
            string("DelayModifier.execTransactionFromModuleReturnData");
        delaySelectorFunctionMap[delayModifier.isModuleEnabled.selector] = string("DelayModifier.isModuleEnabled");
        delaySelectorFunctionMap[delayModifier.getModulesPaginated.selector] =
            string("DelayModifier.getModulesPaginated");
        delaySelectorFunctionMap[delayModifier.setUp.selector] = string("DelayModifier.setUp");
        delaySelectorFunctionMap[delayModifier.setTxCooldown.selector] = string("DelayModifier.setTxCooldown");
        delaySelectorFunctionMap[delayModifier.setTxExpiration.selector] = string("DelayModifier.setTxExpiration");
        delaySelectorFunctionMap[delayModifier.setTxNonce.selector] = string("DelayModifier.setTxNonce");
        delaySelectorFunctionMap[delayModifier.executeNextTx.selector] = string("DelayModifier.executeNextTx");
        delaySelectorFunctionMap[delayModifier.skipExpired.selector] = string("DelayModifier.skipExpired");
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

        /// Adds to invalidate transaction on the Delay Modifier.
        delaySelectorsAllowedDao.push(delayModifier.setTxNonce.selector);
    }

    function _populateRoleMappingSelectorsFunctionName() internal {
        roleSelectorFunctionMap[roleModifier.setUp.selector] = string("RoleModifier.setUp");
        roleSelectorFunctionMap[roleModifier.setMultisend.selector] = string("RoleModifier.setMultisend");
        roleSelectorFunctionMap[roleModifier.allowTarget.selector] = string("RoleModifier.allowTarget");
        roleSelectorFunctionMap[roleModifier.revokeTarget.selector] = string("RoleModifier.revokeTarget");
        roleSelectorFunctionMap[roleModifier.scopeTarget.selector] = string("RoleModifier.scopeTarget");
        roleSelectorFunctionMap[roleModifier.scopeAllowFunction.selector] = string("RoleModifier.scopeAllowFunction");
        roleSelectorFunctionMap[roleModifier.scopeRevokeFunction.selector] = string("RoleModifier.scopeRevokeFunction");
        roleSelectorFunctionMap[roleModifier.scopeFunction.selector] = string("RoleModifier.scopeFunction");
        roleSelectorFunctionMap[roleModifier.scopeFunctionExecutionOptions.selector] =
            string("RoleModifier.scopeFunctionExecutionOptions");
        roleSelectorFunctionMap[roleModifier.scopeParameter.selector] = string("RoleModifier.scopeParameter");
        roleSelectorFunctionMap[roleModifier.scopeParameterAsOneOf.selector] =
            string("RoleModifier.scopeParameterAsOneOf");
        roleSelectorFunctionMap[roleModifier.unscopeParameter.selector] = string("RoleModifier.unscopeParameter");
        roleSelectorFunctionMap[roleModifier.assignRoles.selector] = string("RoleModifier.assignRoles");
        roleSelectorFunctionMap[roleModifier.setDefaultRole.selector] = string("RoleModifier.setDefaultRole");
        roleSelectorFunctionMap[roleModifier.execTransactionWithRole.selector] =
            string("RoleModifier.execTransactionWithRole");
        roleSelectorFunctionMap[roleModifier.execTransactionWithRoleReturnData.selector] =
            string("RoleModifier.execTransactionWithRoleReturnData");
    }

    function _populateRoleSelectors() internal {
        roleSelectors.push(roleModifier.setUp.selector);
        roleSelectors.push(roleModifier.setMultisend.selector);
        roleSelectors.push(roleModifier.allowTarget.selector);
        roleSelectors.push(roleModifier.revokeTarget.selector);
        roleSelectors.push(roleModifier.scopeTarget.selector);
        roleSelectors.push(roleModifier.scopeAllowFunction.selector);
        roleSelectors.push(roleModifier.scopeRevokeFunction.selector);
        roleSelectors.push(roleModifier.scopeFunction.selector);
        roleSelectors.push(roleModifier.scopeFunctionExecutionOptions.selector);
        roleSelectors.push(roleModifier.scopeParameter.selector);
        roleSelectors.push(roleModifier.scopeParameterAsOneOf.selector);
        roleSelectors.push(roleModifier.unscopeParameter.selector);
        roleSelectors.push(roleModifier.assignRoles.selector);
        roleSelectors.push(roleModifier.setDefaultRole.selector);
        roleSelectors.push(roleModifier.execTransactionWithRole.selector);
        roleSelectors.push(roleModifier.execTransactionWithRoleReturnData.selector);
    }

    function _populateMcMappingSelectorsFunctionName() internal {
        mcSelectorFunctionMap[morphoCompound.setDefaultMaxGasForMatching.selector] =
            string("morphoCompound.setDefaultMaxGasForMatching");
        mcSelectorFunctionMap[morphoCompound.setRewardsManager.selector] = string("morphoCompound.setRewardsManager");
        mcSelectorFunctionMap[morphoCompound.setPositionsManager.selector] =
            string("morphoCompound.setPositionsManager");
        mcSelectorFunctionMap[morphoCompound.setInterestRatesManager.selector] =
            string("morphoCompound.setInterestRatesManager");
        mcSelectorFunctionMap[morphoCompound.setTreasuryVault.selector] = string("morphoCompound.setTreasuryVault");
        mcSelectorFunctionMap[morphoCompound.setDustThreshold.selector] = string("morphoCompound.setDustThreshold");
        mcSelectorFunctionMap[morphoCompound.setReserveFactor.selector] = string("morphoCompound.setReserveFactor");
        mcSelectorFunctionMap[morphoCompound.claimToTreasury.selector] = string("morphoCompound.claimToTreasury");
        mcSelectorFunctionMap[morphoCompound.createMarket.selector] = string("morphoCompound.createMarket");
        mcSelectorFunctionMap[morphoCompound.setIsDeprecated.selector] = string("morphoCompound.setIsDeprecated");

        mcSelectorFunctionMap[morphoCompound.setMaxSortedUsers.selector] = string("morphoCompound.setMaxSortedUsers");
        mcSelectorFunctionMap[morphoCompound.setIsP2PDisabled.selector] = string("morphoCompound.setIsP2PDisabled");
        mcSelectorFunctionMap[morphoCompound.setP2PIndexCursor.selector] = string("morphoCompound.setP2PIndexCursor");
        mcSelectorFunctionMap[morphoCompound.setIsPausedForAllMarkets.selector] =
            string("morphoCompound.setIsPausedForAllMarkets");
        mcSelectorFunctionMap[morphoCompound.setIsClaimRewardsPaused.selector] =
            string("morphoCompound.setIsClaimRewardsPaused");
        mcSelectorFunctionMap[morphoCompound.setIsSupplyPaused.selector] = string("morphoCompound.setIsSupplyPaused");
        mcSelectorFunctionMap[morphoCompound.setIsBorrowPaused.selector] = string("morphoCompound.setIsBorrowPaused");
        mcSelectorFunctionMap[morphoCompound.setIsWithdrawPaused.selector] =
            string("morphoCompound.setIsWithdrawPaused");
        mcSelectorFunctionMap[morphoCompound.setIsRepayPaused.selector] = string("morphoCompound.setIsRepayPaused");
        mcSelectorFunctionMap[morphoCompound.setIsLiquidateCollateralPaused.selector] =
            string("morphoCompound.setIsLiquidateCollateralPaused");
        mcSelectorFunctionMap[morphoCompound.setIsLiquidateBorrowPaused.selector] =
            string("morphoCompound.setIsLiquidateBorrowPaused");
    }

    /// @dev 3 threes others selectors are enabled for the operator on Morpho-Compound
    ///      They correspond to functions that have been deprecated following an upgrade but the changes have not been reflected on the Operator's scope.
    ///      0x324ebc55 for claimToTreasury, 0x7f06f7bd for setDefaultMaxGasForMatching (function with different arguments) and 0xcc567180 for setP2PDisabled.
    function _populateMcFunctionSelectors() internal {
        mcSelectorsAdmin.push(morphoCompound.setDefaultMaxGasForMatching.selector);
        mcSelectorsAdmin.push(morphoCompound.setRewardsManager.selector);
        mcSelectorsAdmin.push(morphoCompound.setPositionsManager.selector);
        mcSelectorsAdmin.push(morphoCompound.setInterestRatesManager.selector);
        mcSelectorsAdmin.push(morphoCompound.setTreasuryVault.selector);
        mcSelectorsAdmin.push(morphoCompound.setDustThreshold.selector);
        mcSelectorsAdmin.push(morphoCompound.setReserveFactor.selector);
        mcSelectorsAdmin.push(morphoCompound.claimToTreasury.selector);
        mcSelectorsAdmin.push(morphoCompound.createMarket.selector);
        mcSelectorsAdmin.push(morphoCompound.setIsDeprecated.selector);

        mcSelectorsOperator.push(morphoCompound.setMaxSortedUsers.selector);
        mcSelectorsOperator.push(morphoCompound.setIsP2PDisabled.selector);
        mcSelectorsOperator.push(morphoCompound.setP2PIndexCursor.selector);
        mcSelectorsOperator.push(morphoCompound.setIsPausedForAllMarkets.selector);
        mcSelectorsOperator.push(morphoCompound.setIsClaimRewardsPaused.selector);
        mcSelectorsOperator.push(morphoCompound.setIsSupplyPaused.selector);
        mcSelectorsOperator.push(morphoCompound.setIsBorrowPaused.selector);
        mcSelectorsOperator.push(morphoCompound.setIsWithdrawPaused.selector);
        mcSelectorsOperator.push(morphoCompound.setIsRepayPaused.selector);
        mcSelectorsOperator.push(morphoCompound.setIsLiquidateCollateralPaused.selector);
        mcSelectorsOperator.push(morphoCompound.setIsLiquidateBorrowPaused.selector);
    }

    function _populateMa2MappingSelectorsFunctionName() internal {
        ma2SelectorFunctionMap[morphoAaveV2.setExitPositionsManager.selector] =
            string("morphoAaveV2.setExitPositionsManager");
        ma2SelectorFunctionMap[morphoAaveV2.setEntryPositionsManager.selector] =
            string("morphoAaveV2.setEntryPositionsManager");
        ma2SelectorFunctionMap[morphoAaveV2.setInterestRatesManager.selector] =
            string("morphoAaveV2.setInterestRatesManager");
        ma2SelectorFunctionMap[morphoAaveV2.setTreasuryVault.selector] = string("morphoAaveV2.setTreasuryVault");
        ma2SelectorFunctionMap[morphoAaveV2.createMarket.selector] = string("morphoAaveV2.createMarket");
        ma2SelectorFunctionMap[morphoAaveV2.setReserveFactor.selector] = string("morphoAaveV2.setReserveFactor");
        ma2SelectorFunctionMap[morphoAaveV2.setIsDeprecated.selector] = string("morphoAaveV2.setIsDeprecated");

        ma2SelectorFunctionMap[morphoAaveV2.claimToTreasury.selector] = string("morphoAaveV2.claimToTreasury");
        ma2SelectorFunctionMap[morphoAaveV2.setMaxSortedUsers.selector] = string("morphoAaveV2.setMaxSortedUsers");
        ma2SelectorFunctionMap[morphoAaveV2.setDefaultMaxGasForMatching.selector] =
            string("morphoAaveV2.setDefaultMaxGasForMatching");
        ma2SelectorFunctionMap[morphoAaveV2.setIsP2PDisabled.selector] = string("morphoAaveV2.setIsP2PDisabled");
        ma2SelectorFunctionMap[morphoAaveV2.setP2PIndexCursor.selector] = string("morphoAaveV2.setP2PIndexCursor");
        ma2SelectorFunctionMap[morphoAaveV2.setIsPausedForAllMarkets.selector] =
            string("morphoAaveV2.setIsPausedForAllMarkets");
        ma2SelectorFunctionMap[morphoAaveV2.setIsSupplyPaused.selector] = string("morphoAaveV2.setIsSupplyPaused");
        ma2SelectorFunctionMap[morphoAaveV2.setIsBorrowPaused.selector] = string("morphoAaveV2.setIsBorrowPaused");
        ma2SelectorFunctionMap[morphoAaveV2.setIsWithdrawPaused.selector] = string("morphoAaveV2.setIsWithdrawPaused");
        ma2SelectorFunctionMap[morphoAaveV2.setIsRepayPaused.selector] = string("morphoAaveV2.setIsRepayPaused");
        ma2SelectorFunctionMap[morphoAaveV2.setIsLiquidateCollateralPaused.selector] =
            string("morphoAaveV2.setIsLiquidateCollateralPaused");
        ma2SelectorFunctionMap[morphoAaveV2.setIsLiquidateBorrowPaused.selector] =
            string("morphoAaveV2.setIsLiquidateBorrowPaused");
        ma2SelectorFunctionMap[morphoAaveV2.increaseP2PDeltas.selector] = string("morphoAaveV2.increaseP2PDeltas");
    }

    function _populateMa2FunctionSelectors() internal {
        ma2SelectorsAdmin.push(morphoAaveV2.setExitPositionsManager.selector);
        ma2SelectorsAdmin.push(morphoAaveV2.setEntryPositionsManager.selector);
        ma2SelectorsAdmin.push(morphoAaveV2.setInterestRatesManager.selector);
        ma2SelectorsAdmin.push(morphoAaveV2.setTreasuryVault.selector);
        ma2SelectorsAdmin.push(morphoAaveV2.createMarket.selector);
        ma2SelectorsAdmin.push(morphoAaveV2.setReserveFactor.selector);
        ma2SelectorsAdmin.push(morphoAaveV2.setIsDeprecated.selector);

        ma2SelectorsOperator.push(morphoAaveV2.claimToTreasury.selector);
        ma2SelectorsOperator.push(morphoAaveV2.setMaxSortedUsers.selector);
        ma2SelectorsOperator.push(morphoAaveV2.setDefaultMaxGasForMatching.selector);
        ma2SelectorsOperator.push(morphoAaveV2.setIsP2PDisabled.selector);
        ma2SelectorsOperator.push(morphoAaveV2.setP2PIndexCursor.selector);
        ma2SelectorsOperator.push(morphoAaveV2.setIsPausedForAllMarkets.selector);
        ma2SelectorsOperator.push(morphoAaveV2.setIsSupplyPaused.selector);
        ma2SelectorsOperator.push(morphoAaveV2.setIsBorrowPaused.selector);
        ma2SelectorsOperator.push(morphoAaveV2.setIsWithdrawPaused.selector);
        ma2SelectorsOperator.push(morphoAaveV2.setIsRepayPaused.selector);
        ma2SelectorsOperator.push(morphoAaveV2.setIsLiquidateCollateralPaused.selector);
        ma2SelectorsOperator.push(morphoAaveV2.setIsLiquidateBorrowPaused.selector);
        ma2SelectorsOperator.push(morphoAaveV2.increaseP2PDeltas.selector);
    }

    function _populateMa3MappingSelectorsFunctionName() internal {
        ma3SelectorFunctionMap[morphoAaveV3.createMarket.selector] = string("morphoAaveV3.createMarket");
        ma3SelectorFunctionMap[morphoAaveV3.setPositionsManager.selector] = string("morphoAaveV3.setPositionsManager");
        ma3SelectorFunctionMap[morphoAaveV3.setRewardsManager.selector] = string("morphoAaveV3.setRewardsManager");
        ma3SelectorFunctionMap[morphoAaveV3.setTreasuryVault.selector] = string("morphoAaveV3.setTreasuryVault");
        ma3SelectorFunctionMap[morphoAaveV3.setReserveFactor.selector] = string("morphoAaveV3.setReserveFactor");

        ma3SelectorFunctionMap[morphoAaveV3.increaseP2PDeltas.selector] = string("morphoAaveV3.increaseP2PDeltas");
        ma3SelectorFunctionMap[morphoAaveV3.claimToTreasury.selector] = string("morphoAaveV3.claimToTreasury");
        ma3SelectorFunctionMap[morphoAaveV3.setDefaultIterations.selector] = string("morphoAaveV3.setDefaultIterations");
        ma3SelectorFunctionMap[morphoAaveV3.setP2PIndexCursor.selector] = string("morphoAaveV3.setP2PIndexCursor");
        ma3SelectorFunctionMap[morphoAaveV3.setAssetIsCollateralOnPool.selector] =
            string("morphoAaveV3.setAssetIsCollateralOnPool");
        ma3SelectorFunctionMap[morphoAaveV3.setAssetIsCollateral.selector] = string("morphoAaveV3.setAssetIsCollateral");
        ma3SelectorFunctionMap[morphoAaveV3.setIsClaimRewardsPaused.selector] =
            string("morphoAaveV3.setIsClaimRewardsPaused");
        ma3SelectorFunctionMap[morphoAaveV3.setIsPaused.selector] = string("morphoAaveV3.setIsPaused");
        ma3SelectorFunctionMap[morphoAaveV3.setIsPausedForAllMarkets.selector] =
            string("morphoAaveV3.setIsPausedForAllMarkets");
        ma3SelectorFunctionMap[morphoAaveV3.setIsSupplyPaused.selector] = string("morphoAaveV3.setIsSupplyPaused");
        ma3SelectorFunctionMap[morphoAaveV3.setIsSupplyCollateralPaused.selector] =
            string("morphoAaveV3.setIsSupplyCollateralPaused");
        ma3SelectorFunctionMap[morphoAaveV3.setIsBorrowPaused.selector] = string("morphoAaveV3.setIsBorrowPaused");
        ma3SelectorFunctionMap[morphoAaveV3.setIsRepayPaused.selector] = string("morphoAaveV3.setIsRepayPaused");
        ma3SelectorFunctionMap[morphoAaveV3.setIsWithdrawPaused.selector] = string("morphoAaveV3.setIsWithdrawPaused");
        ma3SelectorFunctionMap[morphoAaveV3.setIsWithdrawCollateralPaused.selector] =
            string("morphoAaveV3.setIsWithdrawCollateralPaused");
        ma3SelectorFunctionMap[morphoAaveV3.setIsLiquidateBorrowPaused.selector] =
            string("morphoAaveV3.setIsLiquidateBorrowPaused");
        ma3SelectorFunctionMap[morphoAaveV3.setIsLiquidateCollateralPaused.selector] =
            string("morphoAaveV3.setIsLiquidateCollateralPaused");
        ma3SelectorFunctionMap[morphoAaveV3.setIsP2PDisabled.selector] = string("morphoAaveV3.setIsP2PDisabled");
        ma3SelectorFunctionMap[morphoAaveV3.setIsDeprecated.selector] = string("morphoAaveV3.setIsDeprecated");
    }

    function _populateMa3FunctionSelectors() internal {
        ma3SelectorsAdmin.push(morphoAaveV3.createMarket.selector);
        ma3SelectorsAdmin.push(morphoAaveV3.setPositionsManager.selector);
        ma3SelectorsAdmin.push(morphoAaveV3.setRewardsManager.selector);
        ma3SelectorsAdmin.push(morphoAaveV3.setTreasuryVault.selector);
        ma3SelectorsAdmin.push(morphoAaveV3.setReserveFactor.selector);

        ma3SelectorsOperator.push(morphoAaveV3.increaseP2PDeltas.selector);
        ma3SelectorsOperator.push(morphoAaveV3.claimToTreasury.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setDefaultIterations.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setP2PIndexCursor.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setAssetIsCollateralOnPool.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setAssetIsCollateral.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setIsClaimRewardsPaused.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setIsPaused.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setIsPausedForAllMarkets.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setIsSupplyPaused.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setIsSupplyCollateralPaused.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setIsBorrowPaused.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setIsRepayPaused.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setIsWithdrawPaused.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setIsWithdrawCollateralPaused.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setIsLiquidateBorrowPaused.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setIsLiquidateCollateralPaused.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setIsP2PDisabled.selector);
        ma3SelectorsOperator.push(morphoAaveV3.setIsDeprecated.selector);
    }
}
