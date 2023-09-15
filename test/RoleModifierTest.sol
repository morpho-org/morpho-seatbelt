// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers/ForkTest.sol";

contract RoleModifierTest is ForkTest {
    using ArrayLib for bytes4[];
    using RoleModifierLib for IRoleModifier;

    function testMorphoDaoRole() public {
        for (uint16 i; i < 100; ++i) {
            if (i == 2) {
                assertTrue(roleModifier.members(i, address(morphoDao)));
            } else {
                assertFalse(roleModifier.members(i, address(morphoDao)));
            }
        }
    }

    function testMorphoOperatorRole() public {
        for (uint16 i; i < 100; ++i) {
            if (i == 1) {
                assertTrue(roleModifier.members(i, address(operator)));
            } else {
                assertFalse(roleModifier.members(i, address(operator)));
            }
        }
    }

    function testSelectorDelayAllowedForDAO() public {
        for (uint256 i; i < delaySelectorsAllowedDao.length; i++) {
            assertTrue(roleModifier.functionIsWildcarded(2, address(delayModifier), delaySelectorsAllowedDao[i]));
        }
    }

    function testSelectorDelayNotAllowedForDAO() public {
        for (uint256 i; i < delaySelectors.length; i++) {
            if (!delaySelectorsAllowedDao.contains(delaySelectors[i])) {
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
            assertFalse(roleModifier.functionIsWildcarded(role, address(morphoCompound), mcSelectorsAdmin[i]));
        }
    }

    function testAdminSelectorNotAllowedForOperatorMorphoAaveV2(uint16 role) public {
        for (uint256 i; i < ma2SelectorsAdmin.length; i++) {
            assertFalse(roleModifier.functionIsWildcarded(role, address(morphoAaveV2), ma2SelectorsAdmin[i]));
        }
    }

    function testAdminSelectorNotAllowedForOperatorMorphoAaveV3(uint16 role) public {
        for (uint256 i; i < ma3SelectorsAdmin.length; i++) {
            assertFalse(roleModifier.functionIsWildcarded(role, address(morphoAaveV3), ma3SelectorsAdmin[i]));
        }
    }
}
