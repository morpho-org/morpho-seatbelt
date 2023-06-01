// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "test/TestSetup.sol";

contract TestLog is TestSetup {
    using RoleHelperLib for IRoles;
    using ConfigLib for Config;

    function testLogMembers() public view {
        _logRoleMembership(0, roleMembers);
        _logRoleMembership(1, roleMembers);
        _logRoleMembership(2, roleMembers);
    }

    function testLogFunctionIsWildcarded() public view {
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for delay modifier");
        _logFunctionIsWildcarded(0, address(delayModifier), delaySelectors);
        _logFunctionIsWildcarded(1, address(delayModifier), delaySelectors);
        _logFunctionIsWildcarded(2, address(delayModifier), delaySelectors);
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for role modifier");
        _logFunctionIsWildcarded(0, address(roleModifier), roleSelectors);
        _logFunctionIsWildcarded(1, address(roleModifier), roleSelectors);
        _logFunctionIsWildcarded(2, address(roleModifier), roleSelectors);
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for Morpho Compound");
        _logFunctionIsWildcarded(0, address(morphoCompound), mcSelectorsOperator);
        _logFunctionIsWildcarded(1, address(morphoCompound), mcSelectorsOperator);
        _logFunctionIsWildcarded(2, address(morphoCompound), mcSelectorsOperator);
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for Morpho Aave V2");
        _logFunctionIsWildcarded(0, address(morphoAaveV2), ma2SelectorsOperator);
        _logFunctionIsWildcarded(1, address(morphoAaveV2), ma2SelectorsOperator);
        _logFunctionIsWildcarded(2, address(morphoAaveV2), ma2SelectorsOperator);
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for Morpho Aave V3");
        _logFunctionIsWildcarded(0, address(morphoAaveV3), ma3SelectorsOperator);
        _logFunctionIsWildcarded(1, address(morphoAaveV3), ma3SelectorsOperator);
        _logFunctionIsWildcarded(2, address(morphoAaveV3), ma3SelectorsOperator);
    }

    function _logRoleMembership(uint16 role, address[] memory members) internal view {
        console2.log("Membership for role %d", role);
        for (uint256 i; i < members.length; i++) {
            if (roleModifier.members(role, members[i])) console2.log("%s", members[i]);
        }
    }

    function _logFunctionIsWildcarded(uint16 role, address target, bytes4[] memory selectors) internal view {
        console2.log("Wildcards for role %d and target %s", role, target);
        uint256 counter;
        for (uint256 i; i < selectors.length; i++) {
            if (roleModifier.functionIsWildcarded(role, target, selectors[i])) {
                console2.logBytes4(selectors[i]);
                counter++;
            }
        }
        if (counter != 0) {
            console2.log("Number of functions expected: %d, Real number: %s", selectors.length, counter);
        }
        console2.log();
    }
}
