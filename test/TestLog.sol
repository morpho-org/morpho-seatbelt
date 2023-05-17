// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "test/TestSetup.sol";

import {Transaction, Operation} from "src/libraries/Types.sol";
import {EnumerableSet} from "@openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import {Strings} from "@openzeppelin-contracts/contracts/utils/Strings.sol";

contract TestLog is TestSetup {
    using RoleHelperLib for IRoles;
    using ConfigLib for Config;
    using Strings for uint256;
    using Strings for address;

    address[] internal roleMembers;
    bytes4[] internal functionSelectors;

    Config internal txConfig;

    function setUp() public virtual override {
        super.setUp();

        _populateMembersToCheck();
        _populateFunctionSelectors();

        // This is so we can just call execTransactionFromModule to simulate executing transactions without signatures.
        _addModule(IAvatar(morphoDao), address(this));
        _addModule(IAvatar(operator), address(this));
        Transaction memory transaction = _getTxData("test");
        morphoDao.execTransactionFromModule(transaction.to, transaction.value, transaction.data, transaction.op);
    }

    function _populateMembersToCheck() internal {
        roleMembers.push(address(operator));
        roleMembers.push(address(morphoDao));
    }

    function _populateFunctionSelectors() internal {
        functionSelectors.push(morpho.createMarket.selector);
        functionSelectors.push(morpho.increaseP2PDeltas.selector);
        functionSelectors.push(morpho.claimToTreasury.selector);
        functionSelectors.push(morpho.setPositionsManager.selector);
        functionSelectors.push(morpho.setRewardsManager.selector);
        functionSelectors.push(morpho.setTreasuryVault.selector);
        functionSelectors.push(morpho.setDefaultIterations.selector);
        functionSelectors.push(morpho.setP2PIndexCursor.selector);
        functionSelectors.push(morpho.setReserveFactor.selector);
        functionSelectors.push(morpho.setAssetIsCollateralOnPool.selector);
        functionSelectors.push(morpho.setAssetIsCollateral.selector);
        functionSelectors.push(morpho.setIsClaimRewardsPaused.selector);
        functionSelectors.push(morpho.setIsPaused.selector);
        functionSelectors.push(morpho.setIsPausedForAllMarkets.selector);
        functionSelectors.push(morpho.setIsSupplyPaused.selector);
        functionSelectors.push(morpho.setIsSupplyCollateralPaused.selector);
        functionSelectors.push(morpho.setIsBorrowPaused.selector);
        functionSelectors.push(morpho.setIsRepayPaused.selector);
        functionSelectors.push(morpho.setIsWithdrawPaused.selector);
        functionSelectors.push(morpho.setIsWithdrawCollateralPaused.selector);
        functionSelectors.push(morpho.setIsLiquidateBorrowPaused.selector);
        functionSelectors.push(morpho.setIsLiquidateCollateralPaused.selector);
        functionSelectors.push(morpho.setIsP2PDisabled.selector);
        functionSelectors.push(morpho.setIsDeprecated.selector);
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

    function testLogMembers() public view {
        _logRoleMembership(0, roleMembers);
        _logRoleMembership(1, roleMembers);
        _logRoleMembership(2, roleMembers);
    }

    function testLogFunctionIsWildcarded() public view {
        _logFunctionIsWildcarded(0);
        _logFunctionIsWildcarded(1);
        _logFunctionIsWildcarded(2);
    }

    function _logRoleMembership(uint16 role, address[] memory members) internal view {
        console2.log(string(abi.encodePacked("Membership for role ", uint256(role).toString())));
        for (uint256 i; i < members.length; i++) {
            if (roleModifier.members(role, members[i])) console2.log(members[i].toHexString());
        }
    }

    function _logFunctionIsWildcarded(uint16 role) internal view {
        console2.log(string(abi.encodePacked("Wildcards for role ", uint256(role).toString())));
        for (uint256 i; i < functionSelectors.length; i++) {
            if (roleModifier.functionIsWildcarded(role, address(morpho), functionSelectors[i])) {
                console2.logBytes4(functionSelectors[i]);
            }
        }
        console2.log();
    }
}
