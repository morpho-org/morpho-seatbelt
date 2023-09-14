// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers/ForkTest.sol";

contract LogTest is ForkTest {
    using RoleModifierLib for IRoleModifier;
    using ConfigLib for Config;

    address[] internal roleMembers;

    function setUp() public virtual {
        roleMembers.push(address(operator));
        roleMembers.push(address(morphoDao));
    }

    function testLogMembers() public view {
        _logRoleMembership(0, roleMembers);
        _logRoleMembership(1, roleMembers);
        _logRoleMembership(2, roleMembers);
    }

    function testLogFunctionIsWildcarded() public view {
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for delay modifier");
        _logFunctionIsWildcarded(0, address(delayModifier), delaySelectorsAllowedDao, delaySelectorFunctionName);
        _logFunctionIsWildcarded(1, address(delayModifier), delaySelectorsAllowedDao, delaySelectorFunctionName);
        _logFunctionIsWildcarded(2, address(delayModifier), delaySelectorsAllowedDao, delaySelectorFunctionName);
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for role modifier");
        _logFunctionIsWildcarded(0, address(roleModifier), roleSelectors, roleSelectorFunctionName);
        _logFunctionIsWildcarded(1, address(roleModifier), roleSelectors, roleSelectorFunctionName);
        _logFunctionIsWildcarded(2, address(roleModifier), roleSelectors, roleSelectorFunctionName);
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for Morpho Compound");
        _logFunctionIsWildcarded(0, address(morphoCompound), mcSelectorsOperator, mcSelectorFunctionName);
        _logFunctionIsWildcarded(1, address(morphoCompound), mcSelectorsOperator, mcSelectorFunctionName);
        _logFunctionIsWildcarded(2, address(morphoCompound), mcSelectorsOperator, mcSelectorFunctionName);
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for Morpho Aave V2");
        _logFunctionIsWildcarded(0, address(morphoAaveV2), ma2SelectorsOperator, ma2SelectorFunctionName);
        _logFunctionIsWildcarded(1, address(morphoAaveV2), ma2SelectorsOperator, ma2SelectorFunctionName);
        _logFunctionIsWildcarded(2, address(morphoAaveV2), ma2SelectorsOperator, ma2SelectorFunctionName);
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for Morpho Aave V3");
        _logFunctionIsWildcarded(0, address(morphoAaveV3), ma3SelectorsOperator, ma3SelectorFunctionName);
        _logFunctionIsWildcarded(1, address(morphoAaveV3), ma3SelectorsOperator, ma3SelectorFunctionName);
        _logFunctionIsWildcarded(2, address(morphoAaveV3), ma3SelectorsOperator, ma3SelectorFunctionName);
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
        mapping(bytes4 => string) storage selectorFunctionName
    ) internal view {
        console2.log("Wildcards for role %d and target %s", role, target);
        uint256 counter;
        for (uint256 i; i < selectors.length; i++) {
            if (roleModifier.functionIsWildcarded(role, target, selectors[i])) {
                console2.logString(selectorFunctionName[selectors[i]]);
                counter++;
            }
        }
        if (counter != 0) {
            console2.log("Number of functions expected: %d, Real number: %s", selectors.length, counter);
        }
        console2.log();
    }
}
