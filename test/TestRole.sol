// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "test/TestSetup.sol";

contract TestRole is TestSetup {
    using RoleHelperLib for IRoles;
    using ConfigLib for Config;

    function testMorphoDaoRole(uint256 role) public {
        assertFalse(roleModifier.members(0, address(morphoDao)), "Role unexpected");
        assertFalse(roleModifier.members(1, address(morphoDao)), "Role unexpected");
        assertTrue(roleModifier.members(2, address(morphoDao)), "Role expected");

        uint16 newRole = uint16(bound(role, 3, type(uint256).max));
        assertFalse(roleModifier.members(newRole, address(morphoDao)));
    }

    function testMorphoOperatorRole(uint256 role) public {
        assertFalse(roleModifier.members(0, address(operator)), "Role unexpected");
        assertTrue(roleModifier.members(1, address(operator)), "Role expected");
        assertFalse(roleModifier.members(2, address(operator)), "Role unexpected");

        uint16 newRole = uint16(bound(role, 3, type(uint256).max));
        assertFalse(roleModifier.members(newRole, address(operator)));
    }

    function testSelectorDelayAllowedForDAO() public {
        for (uint256 i; i < delaySelectorsAllowedDao.length; i++) {
            assertTrue(roleModifier.functionIsWildcarded(2, address(delayModifier), delaySelectorsAllowedDao[i]));
        }
    }

    function testSelectorDelayNotAllowedForDAO() public {
        for (uint256 i; i < delaySelectors.length; i++) {
            if (!delaySelectorAllowedForDao(delaySelectors[i])) {
                assertFalse(roleModifier.functionIsWildcarded(2, address(delayModifier), delaySelectors[i]));
            }
        }
    }

    function testOperatorSelectorAllowedForOperatorMorphoCompound(uint16 role) public {
        vm.assume(role != 1);
        for (uint256 i; i < mcSelectorsOperator.length; i++) {
            assertTrue(roleModifier.functionIsWildcarded(1, address(morphoCompound), mcSelectorsOperator[i]));
            assertFalse(roleModifier.functionIsWildcarded(role, address(morphoCompound), mcSelectorsOperator[i]));
        }
    }

    function testOperatorSelectorAllowedForOperatorMorphoAaveV2(uint16 role) public {
        vm.assume(role != 1);
        for (uint256 i; i < ma2SelectorsOperator.length; i++) {
            assertTrue(roleModifier.functionIsWildcarded(1, address(morphoAaveV2), ma2SelectorsOperator[i]));
            assertFalse(roleModifier.functionIsWildcarded(role, address(morphoAaveV2), ma2SelectorsOperator[i]));
        }
    }

    function testSelectorAllowedForOperatorMorphoAaveV3(uint16 role) public {
        vm.assume(role != 1);
        for (uint256 i; i < ma3SelectorsOperator.length; i++) {
            assertTrue(roleModifier.functionIsWildcarded(1, address(morphoAaveV3), ma3SelectorsOperator[i]));
            assertFalse(roleModifier.functionIsWildcarded(role, address(morphoAaveV3), ma3SelectorsOperator[i]));
        }
    }

    function testAdminSelectorNotAllowedForOperatorMorphoCompound(uint16 role) public {
        for (uint256 i; i < mcSelectorsAdmin.length; i++) {
            assertFalse(roleModifier.functionIsWildcarded(1, address(morphoCompound), mcSelectorsAdmin[i]));
        }
    }

    function testAdminSelectorNotAllowedForOperatorMorphoAaveV2(uint16 role) public {
        for (uint256 i; i < ma2SelectorsAdmin.length; i++) {
            assertFalse(roleModifier.functionIsWildcarded(1, address(morphoAaveV2), ma2SelectorsAdmin[i]));
        }
    }

    function testAdminSelectorNotAllowedForOperatorMorphoAaveV3(uint16 role) public {
        for (uint256 i; i < ma3SelectorsAdmin.length; i++) {
            assertFalse(roleModifier.functionIsWildcarded(1, address(morphoAaveV3), ma3SelectorsAdmin[i]));
        }
    }

    function delaySelectorAllowedForDao(bytes4 selector) internal view returns (bool success) {
        for (uint256 i; i < delaySelectorsAllowedDao.length; ++i) {
            if (selector == delaySelectorsAllowedDao[i]) {
                success = true;
            }
        }
    }
}
