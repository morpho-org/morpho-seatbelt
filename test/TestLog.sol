// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

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
        _logFunctionIsWildcarded(0, address(morphoCompound), mcSelectors);
        _logFunctionIsWildcarded(1, address(morphoCompound), mcSelectors);
        _logFunctionIsWildcarded(2, address(morphoCompound), mcSelectors);
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for Morpho Aave V2");
        _logFunctionIsWildcarded(0, address(morphoAaveV2), ma2Selectors);
        _logFunctionIsWildcarded(1, address(morphoAaveV2), ma2Selectors);
        _logFunctionIsWildcarded(2, address(morphoAaveV2), ma2Selectors);
        console2.log("-------------------------------------------------------");
        console2.log("Function wildcards for Morpho Aave V3");
        _logFunctionIsWildcarded(0, address(morphoAaveV3), ma3Selectors);
        _logFunctionIsWildcarded(1, address(morphoAaveV3), ma3Selectors);
        _logFunctionIsWildcarded(2, address(morphoAaveV3), ma3Selectors);
    }

    function _logRoleMembership(uint16 role, address[] memory members) internal view {
        console2.log("Membership for role %d", role);
        for (uint256 i; i < members.length; i++) {
            if (roleModifier.members(role, members[i])) console2.log("%s", members[i]);
        }
    }

    function _logFunctionIsWildcarded(uint16 role, address target, bytes4[] memory selectors) internal view {
        console2.log("Wildcards for role %d and target %s", role, target);
        for (uint256 i; i < selectors.length; i++) {
            if (roleModifier.functionIsWildcarded(role, target, selectors[i])) {
                console2.logBytes4(selectors[i]);
            }
        }
        console2.log();
    }
}
