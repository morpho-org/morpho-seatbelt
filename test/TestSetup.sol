// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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
        _executeTestTransaction();
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

    function _executeTestTransaction() internal {
        // This is so we can just call execTransactionFromModule to simulate executing transactions without signatures.
        _addModule(IAvatar(morphoDao), address(this));
        _addModule(IAvatar(operator), address(this));

        Transaction memory transaction = _getTxData("Execution");

        morphoDao.execTransactionFromModule(address(delayModifier), 0, _wrapTxData(transaction), Operation.Call);

        vm.warp(block.timestamp + 100_000);
        delayModifier.executeNextTx(transaction.to, transaction.value, transaction.data, transaction.operation);
    }

    function _populateMembersToCheck() internal {
        roleMembers.push(address(operator));
        roleMembers.push(address(morphoDao));
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
}
