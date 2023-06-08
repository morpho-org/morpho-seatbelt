// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "src/interfaces/IModule.sol";
import "test/TestTransactionSetup.sol";

contract TestDAOSetup is TestTransactionSetup {
    // keccak256("guard_manager.guard.address") = 0x4a204f620c8c5ccdca3fd54d003badd85ba500436a431f0cbda4f558c93c34c8
    uint256 public constant GUARD_STORAGE_SLOT =
        uint256(0x4a204f620c8c5ccdca3fd54d003badd85ba500436a431f0cbda4f558c93c34c8);

    function testMorphoAdminAsOwnerOfProtocols() public {
        assertEq(Ownable(address(morphoCompound)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(morphoAaveV2)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(morphoAaveV3)).owner(), address(morphoAdmin));
        assertEq(Ownable(address(proxyAdmin)).owner(), address(morphoAdmin));
    }

    function testRoleModifier() public {
        assertEq(Ownable(address(roleModifier)).owner(), address(morphoAdmin));
        assertEq(IModule(address(roleModifier)).target(), address(morphoAdmin));
        assertEq(IModule(address(roleModifier)).avatar(), address(morphoAdmin));
        assertTrue(roleModifier.isModuleEnabled(address(morphoDao)));
    }

    function testDelayModifier() public {
        assertEq(Ownable(address(delayModifier)).owner(), address(morphoAdmin));
        assertEq(IModule(address(delayModifier)).target(), address(morphoAdmin));
        assertEq(IModule(address(delayModifier)).avatar(), address(morphoAdmin));
        assertTrue(delayModifier.isModuleEnabled(address(morphoDao)));
        assertEq(delayModifier.txCooldown(), 1 days);
        assertEq(delayModifier.txExpiration(), 0);
    }

    function testModules() public {
        // Role 1: operator
        assertEq(roleModifier.defaultRoles(address(operator)), 1);

        // morphoAdmin should accept tx from delay modifier.
        assertTrue(morphoAdmin.isModuleEnabled(address(delayModifier)));

        // morphoAdmin should accept tx from role modifier.
        assertTrue(morphoAdmin.isModuleEnabled(address(roleModifier)));

        // morphoDao should not accept tx from role modifier.
        assertFalse(morphoDao.isModuleEnabled(address(roleModifier)));

        // delay modifier should accept tx from morphoDao.
        assertTrue(delayModifier.isModuleEnabled(address(morphoDao)));

        // role modifier should accept tx from morphoDao.
        assertTrue(roleModifier.isModuleEnabled(address(morphoDao)));

        // delay modifier should not accept tx from operator.
        assertFalse(delayModifier.isModuleEnabled(address(operator)));

        // role modifier should accept tx from operator.
        assertTrue(roleModifier.isModuleEnabled(address(operator)));

        // operator should not accept tx from role modifier.
        assertFalse(operator.isModuleEnabled(address(roleModifier)));
    }

    /// @dev The guard prevents morphoAdmin's signer to submit any tx on the multisig.
    function testScopeGuard() public {
        assertEq(Ownable(address(scopeGuard)).owner(), address(morphoAdmin));
        assertEq(abi.decode(morphoAdmin.getStorageAt(GUARD_STORAGE_SLOT, 1), (address)), scopeGuard);
    }

    function testThresholdSafe() public {
        assertEq(operator.getThreshold(), 3, "Wrong Threshold for Operator");
        assertEq(morphoDao.getThreshold(), 5, "Wrong Threshold for DAO");
    }

    function testRightOwnerMorphoDAO() public {
        address[] memory ownersDao = morphoDao.getOwners();
        assertEq(owners.length, ownersDao.length, "Wrong number of owner for DAO");
        bool success;
        for (uint256 i; i < ownersDao.length; i++) {
            success = false;
            for (uint256 j; j < owners.length; j++) {
                if (ownersDao[i] == owners[j]) {
                    success = true;
                    break;
                }
            }
            assertTrue(success, "Owner not expected");
        }
    }

    function testRightOwnerMorphoOperator() public {
        address[] memory ownersOperator = operator.getOwners();
        assertEq(owners.length, ownersOperator.length, "Wrong number of owner for DAO");
        bool success;
        for (uint256 i; i < ownersOperator.length; i++) {
            success = false;
            for (uint256 j; j < owners.length; j++) {
                if (ownersOperator[i] == owners[j]) {
                    success = true;
                    break;
                }
            }
            assertTrue(success, "Owner not expected");
        }
    }
}
