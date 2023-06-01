// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "test/TestSetup.sol";

contract TestLog is TestSetup {
    using RoleHelperLib for IRoles;
    using ConfigLib for Config;

    function setUp() public virtual override {
        super.setUp();
        // This is so we can just call execTransactionFromModule to simulate executing transactions without signatures.
        _addModule(IAvatar(morphoDao), address(this));
        _addModule(IAvatar(operator), address(this));
        Transaction memory transaction = _getTxData("test");
        morphoDao.execTransactionFromModule(transaction.to, transaction.value, transaction.data, transaction.op);
    }

    function testLogMembers() public view {
        _logRoleMembership(0, roleMembers);
        _logRoleMembership(1, roleMembers);
        _logRoleMembership(2, roleMembers);
    }

    function testLogFunctionIsWildcarded() public view {
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for delay modifier");
        _logFunctionIsWildcarded(0, address(delayModifier), delaySelectorsAllowedDao, delaySelectorFunctionMap);
        _logFunctionIsWildcarded(1, address(delayModifier), delaySelectorsAllowedDao, delaySelectorFunctionMap);
        _logFunctionIsWildcarded(2, address(delayModifier), delaySelectorsAllowedDao, delaySelectorFunctionMap);
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for role modifier");
        _logFunctionIsWildcarded(0, address(roleModifier), roleSelectors, roleSelectorFunctionMap);
        _logFunctionIsWildcarded(1, address(roleModifier), roleSelectors, roleSelectorFunctionMap);
        _logFunctionIsWildcarded(2, address(roleModifier), roleSelectors, roleSelectorFunctionMap);
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for Morpho Compound");
        _logFunctionIsWildcarded(0, address(morphoCompound), mcSelectorsOperator, mcSelectorFunctionMap);
        _logFunctionIsWildcarded(1, address(morphoCompound), mcSelectorsOperator, mcSelectorFunctionMap);
        _logFunctionIsWildcarded(2, address(morphoCompound), mcSelectorsOperator, mcSelectorFunctionMap);
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for Morpho Aave V2");
        _logFunctionIsWildcarded(0, address(morphoAaveV2), ma2SelectorsOperator, ma2SelectorFunctionMap);
        _logFunctionIsWildcarded(1, address(morphoAaveV2), ma2SelectorsOperator, ma2SelectorFunctionMap);
        _logFunctionIsWildcarded(2, address(morphoAaveV2), ma2SelectorsOperator, ma2SelectorFunctionMap);
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for Morpho Aave V3");
        _logFunctionIsWildcarded(0, address(morphoAaveV3), ma3SelectorsOperator, ma3SelectorFunctionMap);
        _logFunctionIsWildcarded(1, address(morphoAaveV3), ma3SelectorsOperator, ma3SelectorFunctionMap);
        _logFunctionIsWildcarded(2, address(morphoAaveV3), ma3SelectorsOperator, ma3SelectorFunctionMap);
    }

    function _logRoleMembership(uint16 role, address[] memory members) internal view {
        console2.log("Membership for role %d", role);
        for (uint256 i; i < members.length; i++) {
            if (roleModifier.members(role, members[i])) console2.log("%s", members[i]);
        }
    }

    function _logFunctionIsWildcarded(
        uint16 role,
        address target,
        bytes4[] memory selectors,
        mapping(bytes4 => string) storage selectorFunctionMap
    ) internal view {
        console2.log("Wildcards for role %d and target %s", role, target);
        uint256 counter;
        for (uint256 i; i < selectors.length; i++) {
            if (roleModifier.functionIsWildcarded(role, target, selectors[i])) {
                console2.logString(selectorFunctionMap[selectors[i]]);
                counter++;
            }
        }
        if (counter != 0) {
            console2.log("Number of functions expected: %d, Real number: %s", selectors.length, counter);
        }
        console2.log();
    }
}
