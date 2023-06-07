// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import {ConfigLib, Config} from "config/ConfigLib.sol";
import {Configured} from "config/Configured.sol";
import {console2} from "@forge-std/console2.sol";
import {Role, TargetAddress, Transaction, Operation} from "src/libraries/Types.sol";
import {RoleHelperLib} from "test/RoleHelperLib.sol";

import {IMorphoCompound} from "src/interfaces/IMorphoCompound.sol";
import {IMorphoAaveV2} from "src/interfaces/IMorphoAaveV2.sol";
import {IMorphoAaveV3} from "src/interfaces/IMorphoAaveV3.sol";
import {IAvatar} from "src/interfaces/IAvatar.sol";
import {ISafe} from "src/interfaces/ISafe.sol";
import {IDelay} from "src/interfaces/IDelay.sol";
import {IRoles} from "src/interfaces/IRoles.sol";
import {Operation} from "src/libraries/Types.sol";

import {MorphoToken, Token} from "@morpho-token/src/MorphoToken.sol";
import {Ownable} from "@openzeppelin-contracts/contracts/access/Ownable.sol";
import {ProxyAdmin} from "@openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

/// @notice The DAO can call all the governance functions including the ones that can be used by Morpho Operator.
/// @notice It just needs to be executed through the Delay Modifier.
contract TestSetup is Test, Configured {
    using ConfigLib for Config;
    using RoleHelperLib for IRoles;

    uint256 forkId;

    ISafe public morphoAdmin;
    ISafe public morphoDao;
    ISafe public morphoAssociation;
    ISafe public morphoLabs;
    ISafe public operator;
    IDelay public delayModifier;
    IRoles public roleModifier;
    address public scopeGuard;

    ProxyAdmin public proxyAdmin;
    IMorphoCompound public morphoCompound;
    IMorphoAaveV2 public morphoAaveV2;
    IMorphoAaveV3 public morphoAaveV3;
    MorphoToken public morphoToken;

    address[] internal owners;

    address internal rewardsDistributorCore;
    address internal rewardsDistributorVaults;

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

    function setUp() public virtual {
        _initConfig();
        _loadConfig();
        _populateMembersToCheck();
        _populateDelaySelectors();
        _populateRoleSelectors();
        _populateMcFunctionSelectors();
        _populateMa2FunctionSelectors();
        _populateMa3FunctionSelectors();
    }

    function _loadConfig() internal virtual override {
        super._loadConfig();
        uint256 forkBlockNumber = networkConfig.getForkBlockNumber();
        if (forkBlockNumber == 0) {
            forkId = vm.createSelectFork(chain.rpcUrl);
        } else {
            forkId = vm.createSelectFork(chain.rpcUrl, forkBlockNumber);
        }

        _loadVaults();

        _loadOwners();

        morphoAdmin = ISafe(networkConfig.getAddress("morphoAdmin"));
        morphoDao = ISafe(networkConfig.getAddress("morphoDao"));
        morphoAssociation = ISafe(networkConfig.getAddress("morphoAssociation"));
        morphoLabs = ISafe(networkConfig.getAddress("morphoLabs"));
        morphoToken = MorphoToken(networkConfig.getAddress("morphoToken"));
        operator = ISafe(networkConfig.getAddress("operator"));
        delayModifier = IDelay(networkConfig.getAddress("delayModifier"));
        roleModifier = IRoles(networkConfig.getAddress("roleModifier"));
        scopeGuard = networkConfig.getAddress("scopeGuard");
        proxyAdmin = ProxyAdmin(networkConfig.getAddress("proxyAdmin"));
        morphoCompound = IMorphoCompound(networkConfig.getAddress("morphoCompound"));
        morphoAaveV2 = IMorphoAaveV2(networkConfig.getAddress("morphoAaveV2"));
        morphoAaveV3 = IMorphoAaveV3(networkConfig.getAddress("morphoAaveV3"));
        rewardsDistributorCore = networkConfig.getAddress("rewardsDistributorCore");
        rewardsDistributorVaults = networkConfig.getAddress("rewardsDistributorVaults");
    }

    function _addModule(IAvatar avatar, address module) internal {
        vm.prank(address(avatar));
        avatar.enableModule(module);
    }

    function _executeTestTransaction(string memory filename) internal {
        // This is so we can just call execTransactionFromModule to simulate executing transactions without signatures.
        _addModule(IAvatar(morphoDao), address(this));
        _addModule(IAvatar(operator), address(this));

        Transaction memory transaction = _getTxData(filename);

        morphoDao.execTransactionFromModule(transaction.to, transaction.value, transaction.data, transaction.operation);

        vm.warp(block.timestamp + delayModifier.txCooldown());
        uint256 txNonce = delayModifier.txNonce();

        Transaction memory unwrappedTransaction = _unwrapTxData(transaction.data);
        bytes32 txHash = delayModifier.getTransactionHash(
            unwrappedTransaction.to,
            unwrappedTransaction.value,
            unwrappedTransaction.data,
            unwrappedTransaction.operation
        );

        bool success;
        while (delayModifier.txHash(txNonce) != txHash) {
            ++txNonce;
            success = true;
        }
        if (success) {
            vm.prank(address(morphoAdmin));
            delayModifier.setTxNonce(txNonce);
        }

        delayModifier.executeNextTx(
            unwrappedTransaction.to,
            unwrappedTransaction.value,
            unwrappedTransaction.data,
            unwrappedTransaction.operation
        );
    }

    function _populateMembersToCheck() internal {
        roleMembers.push(address(operator));
        roleMembers.push(address(morphoDao));
    }

    function _populateDelaySelectors() internal {
        registerSelector(
            delayModifier.enableModule.selector,
            string("delayModifier.enableModule"),
            delaySelectorFunctionMap,
            delaySelectors
        );
        registerSelector(
            delayModifier.disableModule.selector,
            string("delayModifier.disableModule"),
            delaySelectorFunctionMap,
            delaySelectors
        );
        registerSelector(
            delayModifier.execTransactionFromModule.selector,
            string("delayModifier.execTransactionFromModule"),
            delaySelectorFunctionMap,
            delaySelectors
        );
        registerSelector(
            delayModifier.execTransactionFromModuleReturnData.selector,
            string("delayModifier.execTransactionFromModuleReturnData"),
            delaySelectorFunctionMap,
            delaySelectors
        );
        registerSelector(
            delayModifier.isModuleEnabled.selector,
            string("delayModifier.isModuleEnabled"),
            delaySelectorFunctionMap,
            delaySelectors
        );
        registerSelector(
            delayModifier.getModulesPaginated.selector,
            string("delayModifier.getModulesPaginated"),
            delaySelectorFunctionMap,
            delaySelectors
        );
        registerSelector(
            delayModifier.setUp.selector, string("delayModifier.setUp"), delaySelectorFunctionMap, delaySelectors
        );
        registerSelector(
            delayModifier.setTxCooldown.selector,
            string("delayModifier.setTxCooldown"),
            delaySelectorFunctionMap,
            delaySelectors
        );
        registerSelector(
            delayModifier.setTxExpiration.selector,
            string("delayModifier.setTxExpiration"),
            delaySelectorFunctionMap,
            delaySelectors
        );
        registerSelector(
            delayModifier.setTxNonce.selector,
            string("delayModifier.setTxNonce"),
            delaySelectorFunctionMap,
            delaySelectors
        );
        registerSelector(
            delayModifier.executeNextTx.selector,
            string("delayModifier.executeNextTx"),
            delaySelectorFunctionMap,
            delaySelectors
        );
        registerSelector(
            delayModifier.skipExpired.selector,
            string("delayModifier.skipExpired"),
            delaySelectorFunctionMap,
            delaySelectors
        );

        /// Adds to invalidate transaction on the Delay Modifier.
        delaySelectorsAllowedDao.push(delayModifier.setTxNonce.selector);
    }

    function _populateRoleSelectors() internal {
        registerSelector(
            roleModifier.setUp.selector, string("roleModifier.setUp"), roleSelectorFunctionMap, roleSelectors
        );
        registerSelector(
            roleModifier.setMultisend.selector,
            string("roleModifier.setMultisend"),
            roleSelectorFunctionMap,
            roleSelectors
        );
        registerSelector(
            roleModifier.allowTarget.selector,
            string("roleModifier.allowTarget"),
            roleSelectorFunctionMap,
            roleSelectors
        );
        registerSelector(
            roleModifier.revokeTarget.selector,
            string("roleModifier.revokeTarget"),
            roleSelectorFunctionMap,
            roleSelectors
        );
        registerSelector(
            roleModifier.scopeTarget.selector,
            string("roleModifier.scopeTarget"),
            roleSelectorFunctionMap,
            roleSelectors
        );
        registerSelector(
            roleModifier.scopeAllowFunction.selector,
            string("roleModifier.scopeAllowFunction"),
            roleSelectorFunctionMap,
            roleSelectors
        );
        registerSelector(
            roleModifier.scopeRevokeFunction.selector,
            string("roleModifier.scopeRevokeFunction"),
            roleSelectorFunctionMap,
            roleSelectors
        );
        registerSelector(
            roleModifier.scopeFunction.selector,
            string("roleModifier.scopeFunction"),
            roleSelectorFunctionMap,
            roleSelectors
        );
        registerSelector(
            roleModifier.scopeFunctionExecutionOptions.selector,
            string("roleModifier.scopeFunctionExecutionOptions"),
            roleSelectorFunctionMap,
            roleSelectors
        );
        registerSelector(
            roleModifier.scopeParameter.selector,
            string("roleModifier.scopeParameter"),
            roleSelectorFunctionMap,
            roleSelectors
        );
        registerSelector(
            roleModifier.scopeParameterAsOneOf.selector,
            string("roleModifier.scopeParameterAsOneOf"),
            roleSelectorFunctionMap,
            roleSelectors
        );
        registerSelector(
            roleModifier.unscopeParameter.selector,
            string("roleModifier.unscopeParameter"),
            roleSelectorFunctionMap,
            roleSelectors
        );
        registerSelector(
            roleModifier.assignRoles.selector,
            string("roleModifier.assignRoles"),
            roleSelectorFunctionMap,
            roleSelectors
        );
        registerSelector(
            roleModifier.setDefaultRole.selector,
            string("roleModifier.setDefaultRole"),
            roleSelectorFunctionMap,
            roleSelectors
        );
        registerSelector(
            roleModifier.execTransactionWithRole.selector,
            string("roleModifier.execTransactionWithRole"),
            roleSelectorFunctionMap,
            roleSelectors
        );
        registerSelector(
            roleModifier.execTransactionWithRoleReturnData.selector,
            string("roleModifier.execTransactionWithRoleReturnData"),
            roleSelectorFunctionMap,
            roleSelectors
        );
    }

    /// @dev 3 threes others selectors are enabled for the operator on Morpho-Compound
    ///      They correspond to functions that have been deprecated following an upgrade but the changes have not been reflected on the Operator's scope.
    ///      0x324ebc55 for claimToTreasury, 0x7f06f7bd for setDefaultMaxGasForMatching (function with different arguments) and 0xcc567180 for setP2PDisabled.
    function _populateMcFunctionSelectors() internal {
        registerSelector(
            morphoCompound.setDefaultMaxGasForMatching.selector,
            string("morphoCompound.setDefaultMaxGasForMatching"),
            mcSelectorFunctionMap,
            mcSelectorsAdmin
        );
        registerSelector(
            morphoCompound.setRewardsManager.selector,
            string("morphoCompound.setRewardsManager"),
            mcSelectorFunctionMap,
            mcSelectorsAdmin
        );
        registerSelector(
            morphoCompound.setPositionsManager.selector,
            string("morphoCompound.setPositionsManager"),
            mcSelectorFunctionMap,
            mcSelectorsAdmin
        );
        registerSelector(
            morphoCompound.setInterestRatesManager.selector,
            string("morphoCompound.setInterestRatesManager"),
            mcSelectorFunctionMap,
            mcSelectorsAdmin
        );
        registerSelector(
            morphoCompound.setTreasuryVault.selector,
            string("morphoCompound.setTreasuryVault"),
            mcSelectorFunctionMap,
            mcSelectorsAdmin
        );
        registerSelector(
            morphoCompound.setDustThreshold.selector,
            string("morphoCompound.setDustThreshold"),
            mcSelectorFunctionMap,
            mcSelectorsAdmin
        );
        registerSelector(
            morphoCompound.setReserveFactor.selector,
            string("morphoCompound.setReserveFactor"),
            mcSelectorFunctionMap,
            mcSelectorsAdmin
        );
        registerSelector(
            morphoCompound.claimToTreasury.selector,
            string("morphoCompound.claimToTreasury"),
            mcSelectorFunctionMap,
            mcSelectorsAdmin
        );
        registerSelector(
            morphoCompound.createMarket.selector,
            string("morphoCompound.createMarket"),
            mcSelectorFunctionMap,
            mcSelectorsAdmin
        );
        registerSelector(
            morphoCompound.setIsDeprecated.selector,
            string("morphoCompound.setIsDeprecated"),
            mcSelectorFunctionMap,
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

        registerSelector(
            morphoCompound.setMaxSortedUsers.selector,
            string("morphoCompound.setMaxSortedUsers"),
            mcSelectorFunctionMap,
            mcSelectorsOperator
        );
        registerSelector(
            morphoCompound.setIsP2PDisabled.selector,
            string("morphoCompound.setIsP2PDisabled"),
            mcSelectorFunctionMap,
            mcSelectorsOperator
        );
        registerSelector(
            morphoCompound.setP2PIndexCursor.selector,
            string("morphoCompound.setP2PIndexCursor"),
            mcSelectorFunctionMap,
            mcSelectorsOperator
        );
        registerSelector(
            morphoCompound.setIsPausedForAllMarkets.selector,
            string("morphoCompound.setIsPausedForAllMarkets"),
            mcSelectorFunctionMap,
            mcSelectorsOperator
        );
        registerSelector(
            morphoCompound.setIsClaimRewardsPaused.selector,
            string("morphoCompound.setIsClaimRewardsPaused"),
            mcSelectorFunctionMap,
            mcSelectorsOperator
        );
        registerSelector(
            morphoCompound.setIsSupplyPaused.selector,
            string("morphoCompound.setIsSupplyPaused"),
            mcSelectorFunctionMap,
            mcSelectorsOperator
        );
        registerSelector(
            morphoCompound.setIsBorrowPaused.selector,
            string("morphoCompound.setIsBorrowPaused"),
            mcSelectorFunctionMap,
            mcSelectorsOperator
        );
        registerSelector(
            morphoCompound.setIsWithdrawPaused.selector,
            string("morphoCompound.setIsWithdrawPaused"),
            mcSelectorFunctionMap,
            mcSelectorsOperator
        );
        registerSelector(
            morphoCompound.setIsRepayPaused.selector,
            string("morphoCompound.setIsRepayPaused"),
            mcSelectorFunctionMap,
            mcSelectorsOperator
        );
        registerSelector(
            morphoCompound.setIsLiquidateCollateralPaused.selector,
            string("morphoCompound.setIsLiquidateCollateralPaused"),
            mcSelectorFunctionMap,
            mcSelectorsOperator
        );
        registerSelector(
            morphoCompound.setIsLiquidateBorrowPaused.selector,
            string("morphoCompound.setIsLiquidateBorrowPaused"),
            mcSelectorFunctionMap,
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
        registerSelector(
            morphoAaveV2.setExitPositionsManager.selector,
            string("morphoAaveV2.setExitPositionsManager"),
            ma2SelectorFunctionMap,
            ma2SelectorsAdmin
        );
        registerSelector(
            morphoAaveV2.setEntryPositionsManager.selector,
            string("morphoAaveV2.setEntryPositionsManager"),
            ma2SelectorFunctionMap,
            ma2SelectorsAdmin
        );
        registerSelector(
            morphoAaveV2.setInterestRatesManager.selector,
            string("morphoAaveV2.setInterestRatesManager"),
            ma2SelectorFunctionMap,
            ma2SelectorsAdmin
        );
        registerSelector(
            morphoAaveV2.setTreasuryVault.selector,
            string("morphoAaveV2.setTreasuryVault"),
            ma2SelectorFunctionMap,
            ma2SelectorsAdmin
        );
        registerSelector(
            morphoAaveV2.createMarket.selector,
            string("morphoAaveV2.createMarket"),
            ma2SelectorFunctionMap,
            ma2SelectorsAdmin
        );
        registerSelector(
            morphoAaveV2.setReserveFactor.selector,
            string("morphoAaveV2.setReserveFactor"),
            ma2SelectorFunctionMap,
            ma2SelectorsAdmin
        );
        registerSelector(
            morphoAaveV2.setIsDeprecated.selector,
            string("morphoAaveV2.setIsDeprecated"),
            ma2SelectorFunctionMap,
            ma2SelectorsAdmin
        );

        registerSelector(
            morphoAaveV2.claimToTreasury.selector,
            string("morphoAaveV2.claimToTreasury"),
            ma2SelectorFunctionMap,
            ma2SelectorsOperator
        );
        registerSelector(
            morphoAaveV2.setMaxSortedUsers.selector,
            string("morphoAaveV2.setMaxSortedUsers"),
            ma2SelectorFunctionMap,
            ma2SelectorsOperator
        );
        registerSelector(
            morphoAaveV2.setDefaultMaxGasForMatching.selector,
            string("morphoAaveV2.setDefaultMaxGasForMatching"),
            ma2SelectorFunctionMap,
            ma2SelectorsOperator
        );
        registerSelector(
            morphoAaveV2.setIsP2PDisabled.selector,
            string("morphoAaveV2.setIsP2PDisabled"),
            ma2SelectorFunctionMap,
            ma2SelectorsOperator
        );
        registerSelector(
            morphoAaveV2.setP2PIndexCursor.selector,
            string("morphoAaveV2.setP2PIndexCursor"),
            ma2SelectorFunctionMap,
            ma2SelectorsOperator
        );
        registerSelector(
            morphoAaveV2.setIsPausedForAllMarkets.selector,
            string("morphoAaveV2.setIsPausedForAllMarkets"),
            ma2SelectorFunctionMap,
            ma2SelectorsOperator
        );
        registerSelector(
            morphoAaveV2.setIsSupplyPaused.selector,
            string("morphoAaveV2.setIsSupplyPaused"),
            ma2SelectorFunctionMap,
            ma2SelectorsOperator
        );
        registerSelector(
            morphoAaveV2.setIsBorrowPaused.selector,
            string("morphoAaveV2.setIsBorrowPaused"),
            ma2SelectorFunctionMap,
            ma2SelectorsOperator
        );
        registerSelector(
            morphoAaveV2.setIsWithdrawPaused.selector,
            string("morphoAaveV2.setIsWithdrawPaused"),
            ma2SelectorFunctionMap,
            ma2SelectorsOperator
        );
        registerSelector(
            morphoAaveV2.setIsRepayPaused.selector,
            string("morphoAaveV2.setIsRepayPaused"),
            ma2SelectorFunctionMap,
            ma2SelectorsOperator
        );
        registerSelector(
            morphoAaveV2.setIsLiquidateCollateralPaused.selector,
            string("morphoAaveV2.setIsLiquidateCollateralPaused"),
            ma2SelectorFunctionMap,
            ma2SelectorsOperator
        );
        registerSelector(
            morphoAaveV2.setIsLiquidateBorrowPaused.selector,
            string("morphoAaveV2.setIsLiquidateBorrowPaused"),
            ma2SelectorFunctionMap,
            ma2SelectorsOperator
        );
        registerSelector(
            morphoAaveV2.increaseP2PDeltas.selector,
            string("morphoAaveV2.increaseP2PDeltas"),
            ma2SelectorFunctionMap,
            ma2SelectorsOperator
        );
    }

    function _populateMa3FunctionSelectors() internal {
        registerSelector(
            morphoAaveV3.createMarket.selector,
            string("morphoAaveV3.createMarket"),
            ma3SelectorFunctionMap,
            ma3SelectorsAdmin
        );
        registerSelector(
            morphoAaveV3.setPositionsManager.selector,
            string("morphoAaveV3.setPositionsManager"),
            ma3SelectorFunctionMap,
            ma3SelectorsAdmin
        );
        registerSelector(
            morphoAaveV3.setRewardsManager.selector,
            string("morphoAaveV3.setRewardsManager"),
            ma3SelectorFunctionMap,
            ma3SelectorsAdmin
        );
        registerSelector(
            morphoAaveV3.setTreasuryVault.selector,
            string("morphoAaveV3.setTreasuryVault"),
            ma3SelectorFunctionMap,
            ma3SelectorsAdmin
        );
        registerSelector(
            morphoAaveV3.setReserveFactor.selector,
            string("morphoAaveV3.setReserveFactor"),
            ma3SelectorFunctionMap,
            ma3SelectorsAdmin
        );

        registerSelector(
            morphoAaveV3.increaseP2PDeltas.selector,
            string("morphoAaveV3.increaseP2PDeltas"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.claimToTreasury.selector,
            string("morphoAaveV3.claimToTreasury"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setDefaultIterations.selector,
            string("morphoAaveV3.setDefaultIterations"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setP2PIndexCursor.selector,
            string("morphoAaveV3.setP2PIndexCursor"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setAssetIsCollateralOnPool.selector,
            string("morphoAaveV3.setAssetIsCollateralOnPool"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setAssetIsCollateral.selector,
            string("morphoAaveV3.setAssetIsCollateral"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setIsClaimRewardsPaused.selector,
            string("morphoAaveV3.setIsClaimRewardsPaused"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setIsPaused.selector,
            string("morphoAaveV3.setIsPaused"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setIsPausedForAllMarkets.selector,
            string("morphoAaveV3.setIsPausedForAllMarkets"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setIsSupplyPaused.selector,
            string("morphoAaveV3.setIsSupplyPaused"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setIsSupplyCollateralPaused.selector,
            string("morphoAaveV3.setIsSupplyCollateralPaused"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setIsBorrowPaused.selector,
            string("morphoAaveV3.setIsBorrowPaused"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setIsRepayPaused.selector,
            string("morphoAaveV3.setIsRepayPaused"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setIsWithdrawPaused.selector,
            string("morphoAaveV3.setIsWithdrawPaused"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setIsWithdrawCollateralPaused.selector,
            string("morphoAaveV3.setIsWithdrawCollateralPaused"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setIsLiquidateBorrowPaused.selector,
            string("morphoAaveV3.setIsLiquidateBorrowPaused"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setIsLiquidateCollateralPaused.selector,
            string("morphoAaveV3.setIsLiquidateCollateralPaused"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setIsP2PDisabled.selector,
            string("morphoAaveV3.setIsP2PDisabled"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
        registerSelector(
            morphoAaveV3.setIsDeprecated.selector,
            string("morphoAaveV3.setIsDeprecated"),
            ma3SelectorFunctionMap,
            ma3SelectorsOperator
        );
    }

    function registerSelector(
        bytes4 selector,
        string memory functionName,
        mapping(bytes4 => string) storage selectorFunctionMap,
        bytes4[] storage selectorList
    ) internal {
        selectorFunctionMap[selector] = functionName;
        selectorList.push(selector);
    }

    function _loadVaults() internal {
        maWBTC = networkConfig.getAddress("maWBTC");
        maUSDC = networkConfig.getAddress("maUSDC");
        maUSDT = networkConfig.getAddress("maUSDT");
        maCRV = networkConfig.getAddress("maCRV");
        maWETH = networkConfig.getAddress("maWETH");
        maDAI = networkConfig.getAddress("maDAI");
        mcWTBC = networkConfig.getAddress("mcWTBC");
        mcUSDT = networkConfig.getAddress("mcUSDT");
        mcUSDC = networkConfig.getAddress("mcUSDC");
        mcUNI = networkConfig.getAddress("mcUNI");
        mcCOMP = networkConfig.getAddress("mcCOMP");
        mcWETH = networkConfig.getAddress("mcWETH");
        mcDAI = networkConfig.getAddress("mcDAI");
    }

    function _loadOwners() internal {
        owners = networkConfig.getOwners();
    }
}
