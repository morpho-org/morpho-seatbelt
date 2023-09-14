// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ISafe} from "src/interfaces/ISafe.sol";
import {IDelayModifier} from "src/interfaces/IDelayModifier.sol";
import {IRoleModifier} from "src/interfaces/IRoleModifier.sol";
import {IMorphoCompound} from "src/interfaces/IMorphoCompound.sol";
import {IMorphoAaveV2} from "src/interfaces/IMorphoAaveV2.sol";
import {IMorphoAaveV3} from "src/interfaces/IMorphoAaveV3.sol";
import {MorphoToken} from "@morpho-token/MorphoToken.sol";

import {Config, ConfigLib} from "config/ConfigLib.sol";
import {StdChains, VmSafe} from "@forge-std/StdChains.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract Configured is StdChains {
    using ConfigLib for Config;

    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    Config internal CONFIG;

    ISafe public morphoAdmin;
    ISafe public morphoDao;
    ISafe public morphoAssociation;
    ISafe public morphoLabs;
    ISafe public operator;
    IDelayModifier public delayModifier;
    IRoleModifier public roleModifier;
    address public scopeGuard;

    MorphoToken public morphoToken;
    ProxyAdmin public proxyAdmin;
    IMorphoAaveV2 public morphoAaveV2;
    IMorphoAaveV3 public morphoAaveV3;
    IMorphoCompound public morphoCompound;
    address internal rewardsDistributorCore;
    address internal rewardsDistributorVaults;

    bytes4[] internal delaySelectors;
    bytes4[] internal delaySelectorsAllowedDao;
    bytes4[] internal roleSelectors;
    bytes4[] internal mcSelectorsOperator;
    bytes4[] internal ma2SelectorsOperator;
    bytes4[] internal ma3SelectorsOperator;
    bytes4[] internal mcSelectorsAdmin;
    bytes4[] internal ma2SelectorsAdmin;
    bytes4[] internal ma3SelectorsAdmin;

    mapping(bytes4 => string) mcSelectorFunctionName;
    mapping(bytes4 => string) ma2SelectorFunctionName;
    mapping(bytes4 => string) ma3SelectorFunctionName;

    mapping(bytes4 => string) delaySelectorFunctionName;
    mapping(bytes4 => string) roleSelectorFunctionName;

    address internal maWBTC;
    address internal maUSDC;
    address internal maUSDT;
    address internal maCRV;
    address internal maWETH;
    address internal maDAI;
    address internal mcWTBC;
    address internal mcUSDT;
    address internal mcUSDC;
    address internal mcUNI;
    address internal mcCOMP;
    address internal mcWETH;
    address internal mcDAI;

    constructor() {
        _initConfig();
        _loadConfig();

        _populateDelaySelectors();
        _populateRoleSelectors();
        _populateMcFunctionSelectors();
        _populateMa2FunctionSelectors();
        _populateMa3FunctionSelectors();
    }

    function _network() internal view virtual returns (string memory) {
        try vm.envString("NETWORK") returns (string memory network) {
            return network;
        } catch {
            return "ethereum-mainnet";
        }
    }

    function _rpcAlias() internal virtual returns (string memory) {
        return CONFIG.getRpcAlias();
    }

    function _forkBlockNumber() internal virtual returns (uint256) {
        return CONFIG.getForkBlockNumber();
    }

    function _initConfig() internal returns (Config storage) {
        if (bytes(CONFIG.json).length == 0) {
            string memory path = string.concat("config/networks/", _network(), ".json");

            CONFIG.json = vm.readFile(path);
        }

        return CONFIG;
    }

    function _loadConfig() internal virtual {
        morphoAdmin = ISafe(CONFIG.getAddress("morphoAdmin"));
        morphoDao = ISafe(CONFIG.getAddress("morphoDao"));
        morphoAssociation = ISafe(CONFIG.getAddress("morphoAssociation"));
        morphoLabs = ISafe(CONFIG.getAddress("morphoLabs"));
        operator = ISafe(CONFIG.getAddress("operator"));
        delayModifier = IDelayModifier(CONFIG.getAddress("delayModifier"));
        roleModifier = IRoleModifier(CONFIG.getAddress("roleModifier"));
        scopeGuard = CONFIG.getAddress("scopeGuard");

        morphoToken = MorphoToken(CONFIG.getAddress("morphoToken"));
        proxyAdmin = ProxyAdmin(CONFIG.getAddress("proxyAdmin"));
        morphoCompound = IMorphoCompound(CONFIG.getAddress("morphoCompound"));
        morphoAaveV2 = IMorphoAaveV2(CONFIG.getAddress("morphoAaveV2"));
        morphoAaveV3 = IMorphoAaveV3(CONFIG.getAddress("morphoAaveV3"));

        rewardsDistributorCore = CONFIG.getAddress("rewardsDistributorCore");
        rewardsDistributorVaults = CONFIG.getAddress("rewardsDistributorVaults");

        maWBTC = CONFIG.getAddress("maWBTC");
        maUSDC = CONFIG.getAddress("maUSDC");
        maUSDT = CONFIG.getAddress("maUSDT");
        maCRV = CONFIG.getAddress("maCRV");
        maWETH = CONFIG.getAddress("maWETH");
        maDAI = CONFIG.getAddress("maDAI");
        mcWTBC = CONFIG.getAddress("mcWTBC");
        mcUSDT = CONFIG.getAddress("mcUSDT");
        mcUSDC = CONFIG.getAddress("mcUSDC");
        mcUNI = CONFIG.getAddress("mcUNI");
        mcCOMP = CONFIG.getAddress("mcCOMP");
        mcWETH = CONFIG.getAddress("mcWETH");
        mcDAI = CONFIG.getAddress("mcDAI");
    }

    function _registerSelector(
        bytes4 selector,
        string memory functionName,
        mapping(bytes4 => string) storage selectorFunctionName,
        bytes4[] storage selectors
    ) internal {
        selectorFunctionName[selector] = functionName;
        selectors.push(selector);
    }

    function _populateDelaySelectors() internal {
        _registerSelector(
            delayModifier.enableModule.selector,
            string("delayModifier.enableModule"),
            delaySelectorFunctionName,
            delaySelectors
        );
        _registerSelector(
            delayModifier.disableModule.selector,
            string("delayModifier.disableModule"),
            delaySelectorFunctionName,
            delaySelectors
        );
        _registerSelector(
            delayModifier.execTransactionFromModule.selector,
            string("delayModifier.execTransactionFromModule"),
            delaySelectorFunctionName,
            delaySelectors
        );
        _registerSelector(
            delayModifier.execTransactionFromModuleReturnData.selector,
            string("delayModifier.execTransactionFromModuleReturnData"),
            delaySelectorFunctionName,
            delaySelectors
        );
        _registerSelector(
            delayModifier.isModuleEnabled.selector,
            string("delayModifier.isModuleEnabled"),
            delaySelectorFunctionName,
            delaySelectors
        );
        _registerSelector(
            delayModifier.getModulesPaginated.selector,
            string("delayModifier.getModulesPaginated"),
            delaySelectorFunctionName,
            delaySelectors
        );
        _registerSelector(
            delayModifier.setUp.selector, string("delayModifier.setUp"), delaySelectorFunctionName, delaySelectors
        );
        _registerSelector(
            delayModifier.setTxCooldown.selector,
            string("delayModifier.setTxCooldown"),
            delaySelectorFunctionName,
            delaySelectors
        );
        _registerSelector(
            delayModifier.setTxExpiration.selector,
            string("delayModifier.setTxExpiration"),
            delaySelectorFunctionName,
            delaySelectors
        );
        _registerSelector(
            delayModifier.setTxNonce.selector,
            string("delayModifier.setTxNonce"),
            delaySelectorFunctionName,
            delaySelectors
        );
        _registerSelector(
            delayModifier.executeNextTx.selector,
            string("delayModifier.executeNextTx"),
            delaySelectorFunctionName,
            delaySelectors
        );
        _registerSelector(
            delayModifier.skipExpired.selector,
            string("delayModifier.skipExpired"),
            delaySelectorFunctionName,
            delaySelectors
        );

        /// Adds to invalidate transaction on the Delay Modifier.
        delaySelectorsAllowedDao.push(delayModifier.setTxNonce.selector);
    }

    function _populateRoleSelectors() internal {
        _registerSelector(
            roleModifier.setUp.selector, string("roleModifier.setUp"), roleSelectorFunctionName, roleSelectors
        );
        _registerSelector(
            roleModifier.setMultisend.selector,
            string("roleModifier.setMultisend"),
            roleSelectorFunctionName,
            roleSelectors
        );
        _registerSelector(
            roleModifier.allowTarget.selector,
            string("roleModifier.allowTarget"),
            roleSelectorFunctionName,
            roleSelectors
        );
        _registerSelector(
            roleModifier.revokeTarget.selector,
            string("roleModifier.revokeTarget"),
            roleSelectorFunctionName,
            roleSelectors
        );
        _registerSelector(
            roleModifier.scopeTarget.selector,
            string("roleModifier.scopeTarget"),
            roleSelectorFunctionName,
            roleSelectors
        );
        _registerSelector(
            roleModifier.scopeAllowFunction.selector,
            string("roleModifier.scopeAllowFunction"),
            roleSelectorFunctionName,
            roleSelectors
        );
        _registerSelector(
            roleModifier.scopeRevokeFunction.selector,
            string("roleModifier.scopeRevokeFunction"),
            roleSelectorFunctionName,
            roleSelectors
        );
        _registerSelector(
            roleModifier.scopeFunction.selector,
            string("roleModifier.scopeFunction"),
            roleSelectorFunctionName,
            roleSelectors
        );
        _registerSelector(
            roleModifier.scopeFunctionExecutionOptions.selector,
            string("roleModifier.scopeFunctionExecutionOptions"),
            roleSelectorFunctionName,
            roleSelectors
        );
        _registerSelector(
            roleModifier.scopeParameter.selector,
            string("roleModifier.scopeParameter"),
            roleSelectorFunctionName,
            roleSelectors
        );
        _registerSelector(
            roleModifier.scopeParameterAsOneOf.selector,
            string("roleModifier.scopeParameterAsOneOf"),
            roleSelectorFunctionName,
            roleSelectors
        );
        _registerSelector(
            roleModifier.unscopeParameter.selector,
            string("roleModifier.unscopeParameter"),
            roleSelectorFunctionName,
            roleSelectors
        );
        _registerSelector(
            roleModifier.assignRoles.selector,
            string("roleModifier.assignRoles"),
            roleSelectorFunctionName,
            roleSelectors
        );
        _registerSelector(
            roleModifier.setDefaultRole.selector,
            string("roleModifier.setDefaultRole"),
            roleSelectorFunctionName,
            roleSelectors
        );
        _registerSelector(
            roleModifier.execTransactionWithRole.selector,
            string("roleModifier.execTransactionWithRole"),
            roleSelectorFunctionName,
            roleSelectors
        );
        _registerSelector(
            roleModifier.execTransactionWithRoleReturnData.selector,
            string("roleModifier.execTransactionWithRoleReturnData"),
            roleSelectorFunctionName,
            roleSelectors
        );
    }

    /// @dev 3 threes others selectors are enabled for the operator on Morpho-Compound
    ///      They correspond to functions that have been deprecated following an upgrade but the changes have not been reflected on the Operator's scope.
    ///      0x324ebc55 for claimToTreasury, 0x7f06f7bd for setDefaultMaxGasForMatching (function with different arguments) and 0xcc567180 for setP2PDisabled.
    function _populateMcFunctionSelectors() internal {
        _registerSelector(
            morphoCompound.setDefaultMaxGasForMatching.selector,
            string("morphoCompound.setDefaultMaxGasForMatching"),
            mcSelectorFunctionName,
            mcSelectorsAdmin
        );
        _registerSelector(
            morphoCompound.setRewardsManager.selector,
            string("morphoCompound.setRewardsManager"),
            mcSelectorFunctionName,
            mcSelectorsAdmin
        );
        _registerSelector(
            morphoCompound.setPositionsManager.selector,
            string("morphoCompound.setPositionsManager"),
            mcSelectorFunctionName,
            mcSelectorsAdmin
        );
        _registerSelector(
            morphoCompound.setInterestRatesManager.selector,
            string("morphoCompound.setInterestRatesManager"),
            mcSelectorFunctionName,
            mcSelectorsAdmin
        );
        _registerSelector(
            morphoCompound.setTreasuryVault.selector,
            string("morphoCompound.setTreasuryVault"),
            mcSelectorFunctionName,
            mcSelectorsAdmin
        );
        _registerSelector(
            morphoCompound.setDustThreshold.selector,
            string("morphoCompound.setDustThreshold"),
            mcSelectorFunctionName,
            mcSelectorsAdmin
        );
        _registerSelector(
            morphoCompound.setReserveFactor.selector,
            string("morphoCompound.setReserveFactor"),
            mcSelectorFunctionName,
            mcSelectorsAdmin
        );
        _registerSelector(
            morphoCompound.claimToTreasury.selector,
            string("morphoCompound.claimToTreasury"),
            mcSelectorFunctionName,
            mcSelectorsAdmin
        );
        _registerSelector(
            morphoCompound.createMarket.selector,
            string("morphoCompound.createMarket"),
            mcSelectorFunctionName,
            mcSelectorsAdmin
        );
        _registerSelector(
            morphoCompound.setIsDeprecated.selector,
            string("morphoCompound.setIsDeprecated"),
            mcSelectorFunctionName,
            mcSelectorsAdmin
        );
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

        _registerSelector(
            morphoCompound.setMaxSortedUsers.selector,
            string("morphoCompound.setMaxSortedUsers"),
            mcSelectorFunctionName,
            mcSelectorsOperator
        );
        _registerSelector(
            morphoCompound.setIsP2PDisabled.selector,
            string("morphoCompound.setIsP2PDisabled"),
            mcSelectorFunctionName,
            mcSelectorsOperator
        );
        _registerSelector(
            morphoCompound.setP2PIndexCursor.selector,
            string("morphoCompound.setP2PIndexCursor"),
            mcSelectorFunctionName,
            mcSelectorsOperator
        );
        _registerSelector(
            morphoCompound.setIsPausedForAllMarkets.selector,
            string("morphoCompound.setIsPausedForAllMarkets"),
            mcSelectorFunctionName,
            mcSelectorsOperator
        );
        _registerSelector(
            morphoCompound.setIsClaimRewardsPaused.selector,
            string("morphoCompound.setIsClaimRewardsPaused"),
            mcSelectorFunctionName,
            mcSelectorsOperator
        );
        _registerSelector(
            morphoCompound.setIsSupplyPaused.selector,
            string("morphoCompound.setIsSupplyPaused"),
            mcSelectorFunctionName,
            mcSelectorsOperator
        );
        _registerSelector(
            morphoCompound.setIsBorrowPaused.selector,
            string("morphoCompound.setIsBorrowPaused"),
            mcSelectorFunctionName,
            mcSelectorsOperator
        );
        _registerSelector(
            morphoCompound.setIsWithdrawPaused.selector,
            string("morphoCompound.setIsWithdrawPaused"),
            mcSelectorFunctionName,
            mcSelectorsOperator
        );
        _registerSelector(
            morphoCompound.setIsRepayPaused.selector,
            string("morphoCompound.setIsRepayPaused"),
            mcSelectorFunctionName,
            mcSelectorsOperator
        );
        _registerSelector(
            morphoCompound.setIsLiquidateCollateralPaused.selector,
            string("morphoCompound.setIsLiquidateCollateralPaused"),
            mcSelectorFunctionName,
            mcSelectorsOperator
        );
        _registerSelector(
            morphoCompound.setIsLiquidateBorrowPaused.selector,
            string("morphoCompound.setIsLiquidateBorrowPaused"),
            mcSelectorFunctionName,
            mcSelectorsOperator
        );
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

    function _populateMa2FunctionSelectors() internal {
        _registerSelector(
            morphoAaveV2.setExitPositionsManager.selector,
            string("morphoAaveV2.setExitPositionsManager"),
            ma2SelectorFunctionName,
            ma2SelectorsAdmin
        );
        _registerSelector(
            morphoAaveV2.setEntryPositionsManager.selector,
            string("morphoAaveV2.setEntryPositionsManager"),
            ma2SelectorFunctionName,
            ma2SelectorsAdmin
        );
        _registerSelector(
            morphoAaveV2.setInterestRatesManager.selector,
            string("morphoAaveV2.setInterestRatesManager"),
            ma2SelectorFunctionName,
            ma2SelectorsAdmin
        );
        _registerSelector(
            morphoAaveV2.setTreasuryVault.selector,
            string("morphoAaveV2.setTreasuryVault"),
            ma2SelectorFunctionName,
            ma2SelectorsAdmin
        );
        _registerSelector(
            morphoAaveV2.createMarket.selector,
            string("morphoAaveV2.createMarket"),
            ma2SelectorFunctionName,
            ma2SelectorsAdmin
        );
        _registerSelector(
            morphoAaveV2.setReserveFactor.selector,
            string("morphoAaveV2.setReserveFactor"),
            ma2SelectorFunctionName,
            ma2SelectorsAdmin
        );
        _registerSelector(
            morphoAaveV2.setIsDeprecated.selector,
            string("morphoAaveV2.setIsDeprecated"),
            ma2SelectorFunctionName,
            ma2SelectorsAdmin
        );

        _registerSelector(
            morphoAaveV2.claimToTreasury.selector,
            string("morphoAaveV2.claimToTreasury"),
            ma2SelectorFunctionName,
            ma2SelectorsOperator
        );
        _registerSelector(
            morphoAaveV2.setMaxSortedUsers.selector,
            string("morphoAaveV2.setMaxSortedUsers"),
            ma2SelectorFunctionName,
            ma2SelectorsOperator
        );
        _registerSelector(
            morphoAaveV2.setDefaultMaxGasForMatching.selector,
            string("morphoAaveV2.setDefaultMaxGasForMatching"),
            ma2SelectorFunctionName,
            ma2SelectorsOperator
        );
        _registerSelector(
            morphoAaveV2.setIsP2PDisabled.selector,
            string("morphoAaveV2.setIsP2PDisabled"),
            ma2SelectorFunctionName,
            ma2SelectorsOperator
        );
        _registerSelector(
            morphoAaveV2.setP2PIndexCursor.selector,
            string("morphoAaveV2.setP2PIndexCursor"),
            ma2SelectorFunctionName,
            ma2SelectorsOperator
        );
        _registerSelector(
            morphoAaveV2.setIsPausedForAllMarkets.selector,
            string("morphoAaveV2.setIsPausedForAllMarkets"),
            ma2SelectorFunctionName,
            ma2SelectorsOperator
        );
        _registerSelector(
            morphoAaveV2.setIsSupplyPaused.selector,
            string("morphoAaveV2.setIsSupplyPaused"),
            ma2SelectorFunctionName,
            ma2SelectorsOperator
        );
        _registerSelector(
            morphoAaveV2.setIsBorrowPaused.selector,
            string("morphoAaveV2.setIsBorrowPaused"),
            ma2SelectorFunctionName,
            ma2SelectorsOperator
        );
        _registerSelector(
            morphoAaveV2.setIsWithdrawPaused.selector,
            string("morphoAaveV2.setIsWithdrawPaused"),
            ma2SelectorFunctionName,
            ma2SelectorsOperator
        );
        _registerSelector(
            morphoAaveV2.setIsRepayPaused.selector,
            string("morphoAaveV2.setIsRepayPaused"),
            ma2SelectorFunctionName,
            ma2SelectorsOperator
        );
        _registerSelector(
            morphoAaveV2.setIsLiquidateCollateralPaused.selector,
            string("morphoAaveV2.setIsLiquidateCollateralPaused"),
            ma2SelectorFunctionName,
            ma2SelectorsOperator
        );
        _registerSelector(
            morphoAaveV2.setIsLiquidateBorrowPaused.selector,
            string("morphoAaveV2.setIsLiquidateBorrowPaused"),
            ma2SelectorFunctionName,
            ma2SelectorsOperator
        );
        _registerSelector(
            morphoAaveV2.increaseP2PDeltas.selector,
            string("morphoAaveV2.increaseP2PDeltas"),
            ma2SelectorFunctionName,
            ma2SelectorsOperator
        );
    }

    function _populateMa3FunctionSelectors() internal {
        _registerSelector(
            morphoAaveV3.createMarket.selector,
            string("morphoAaveV3.createMarket"),
            ma3SelectorFunctionName,
            ma3SelectorsAdmin
        );
        _registerSelector(
            morphoAaveV3.setPositionsManager.selector,
            string("morphoAaveV3.setPositionsManager"),
            ma3SelectorFunctionName,
            ma3SelectorsAdmin
        );
        _registerSelector(
            morphoAaveV3.setRewardsManager.selector,
            string("morphoAaveV3.setRewardsManager"),
            ma3SelectorFunctionName,
            ma3SelectorsAdmin
        );
        _registerSelector(
            morphoAaveV3.setTreasuryVault.selector,
            string("morphoAaveV3.setTreasuryVault"),
            ma3SelectorFunctionName,
            ma3SelectorsAdmin
        );
        _registerSelector(
            morphoAaveV3.setReserveFactor.selector,
            string("morphoAaveV3.setReserveFactor"),
            ma3SelectorFunctionName,
            ma3SelectorsAdmin
        );

        _registerSelector(
            morphoAaveV3.increaseP2PDeltas.selector,
            string("morphoAaveV3.increaseP2PDeltas"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.claimToTreasury.selector,
            string("morphoAaveV3.claimToTreasury"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setDefaultIterations.selector,
            string("morphoAaveV3.setDefaultIterations"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setP2PIndexCursor.selector,
            string("morphoAaveV3.setP2PIndexCursor"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setAssetIsCollateralOnPool.selector,
            string("morphoAaveV3.setAssetIsCollateralOnPool"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setAssetIsCollateral.selector,
            string("morphoAaveV3.setAssetIsCollateral"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setIsClaimRewardsPaused.selector,
            string("morphoAaveV3.setIsClaimRewardsPaused"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setIsPaused.selector,
            string("morphoAaveV3.setIsPaused"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setIsPausedForAllMarkets.selector,
            string("morphoAaveV3.setIsPausedForAllMarkets"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setIsSupplyPaused.selector,
            string("morphoAaveV3.setIsSupplyPaused"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setIsSupplyCollateralPaused.selector,
            string("morphoAaveV3.setIsSupplyCollateralPaused"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setIsBorrowPaused.selector,
            string("morphoAaveV3.setIsBorrowPaused"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setIsRepayPaused.selector,
            string("morphoAaveV3.setIsRepayPaused"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setIsWithdrawPaused.selector,
            string("morphoAaveV3.setIsWithdrawPaused"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setIsWithdrawCollateralPaused.selector,
            string("morphoAaveV3.setIsWithdrawCollateralPaused"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setIsLiquidateBorrowPaused.selector,
            string("morphoAaveV3.setIsLiquidateBorrowPaused"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setIsLiquidateCollateralPaused.selector,
            string("morphoAaveV3.setIsLiquidateCollateralPaused"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setIsP2PDisabled.selector,
            string("morphoAaveV3.setIsP2PDisabled"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
        _registerSelector(
            morphoAaveV3.setIsDeprecated.selector,
            string("morphoAaveV3.setIsDeprecated"),
            ma3SelectorFunctionName,
            ma3SelectorsOperator
        );
    }
}
